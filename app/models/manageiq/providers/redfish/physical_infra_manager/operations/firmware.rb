module ManageIQ::Providers::Redfish
  module PhysicalInfraManager::Operations::Firmware
    def update_firmware_async(firmware_binary, servers)
      validate_update_firmware(firmware_binary, servers)

      with_provider_connection do |client|
        update_service = client.UpdateService
        raise MiqException::MiqFirmwareUpdateError, 'UpdateService is not enabled' unless update_service

        protocol, url = compatible_firmware_url(update_service, firmware_binary)

        response = update_service.Actions["#UpdateService.SimpleUpdate"].post(
          :field   => 'target',
          :payload => {
            :ImageURI         => url,
            :TransferProtocol => protocol,
            :Targets          => servers.map(&:ems_ref),
          }
        )

        unless [200, 202].include?(response.status)
          raise MiqException::MiqFirmwareUpdateError,
                "Cannot update firmware: (#{response.status}) #{response.data[:body]}"
        end

        response
      end
    end

    def compatible_firmware_url(update_service, firmware_binary)
      update_action = update_service.Actions['#UpdateService.SimpleUpdate']
      requested = update_action['TransferProtocol@Redfish.AllowableValues']
      requested ||= begin
        params = update_action['TransferProtocol@Redfish.ActionInfo']&.Parameters || []
        params.find { |p| p.Name == 'TransferProtocol' }&.AllowableValues
      end
      if requested.blank?
        raise MiqException::MiqFirmwareUpdateError, 'Redfish supports zero transfer protocols'
      end

      url = firmware_binary.endpoints.map(&:url).find { |u| requested.include?(u.split('://').first.upcase) }
      raise MiqException::MiqFirmwareUpdateError, 'No compatible transfer protocol' unless url

      [url.split('://').first.upcase, url]
    end

    private

    def validate_update_firmware(firmware_binary, servers)
      raise MiqException::MiqFirmwareUpdateError, 'At least one server must be selected' if servers.empty?

      incompatible = servers.reject { |s| s.firmware_compatible?(firmware_binary) }
      unless incompatible.empty?
        raise MiqException::MiqFirmwareUpdateError, "Servers not compatible with firmware: #{incompatible.map(&:id)}"
      end
    end
  end
end
