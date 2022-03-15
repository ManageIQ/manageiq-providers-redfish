module ManageIQ::Providers::Redfish::PhysicalInfraManager::FirmwareUpdateTask::StateMachine
  def start_firmware_update
    update_and_notify_parent(:message => msg('start firmware update'))
    signal :trigger_firmware_update
  end

  def trigger_firmware_update
    update_and_notify_parent(:message => msg('trigger firmware update via Redfish'))
    unless (firmware_binary = FirmwareBinary.find_by(:id => options[:firmware_binary_id]))
      raise MiqException::MiqFirmwareUpdateError, "FirmwareBinary with id #{options[:firmware_binary_id]} not found"
    end
    unless (servers = PhysicalServer.where(:id => options[:src_ids])) && servers.size == options[:src_ids].size
      raise MiqException::MiqFirmwareUpdateError, "At least one PhysicalServer of #{options[:src_ids]} not found"
    end

    response = miq_request.affected_ems.update_firmware_async(firmware_binary, servers)
    if !response.done?
      phase_context[:monitor] = response.to_h
      signal :poll_firmware_update
    else
      signal :done_firmware_update
    end
  end

  def poll_firmware_update
    update_and_notify_parent(:message => msg('poll firmware update'))
    miq_request.affected_ems.with_provider_connection do |client|
      require "redfish_client"

      old_response = RedfishClient::Response.from_hash(phase_context[:monitor])
      response = client.get(:path => old_response.monitor)
      if response.done?
        signal :done_firmware_update
      else
        phase_context[:monitor] = response.to_h
        requeue_phase
      end
    end
  end
end
