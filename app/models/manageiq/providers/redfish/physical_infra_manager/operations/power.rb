module ManageIQ::Providers::Redfish
  module PhysicalInfraManager::Operations::Power
    # Keep this in sync with app/models/physical_server/operations/power.rb in
    # core and ResetType enum in Redfish Resource type. Name of the method
    # comes from the core and the action name used in the reset call from the
    # ResetType enum.
    #
    # NOTE: Not all reset operations are implemented on all servers, so any of
    # the methods listed here can fail. We need to find a way to let those
    # failures bubble up to the user interface somehow or risk having a
    # completely useless tool.

    def power_on(server, _options)
      reset_server(server, "On")
    end

    def power_off(server, _options)
      reset_server(server, "GracefulShutdown")
    end

    def power_off_now(server, _options)
      reset_server(server, "ForceOff")
    end

    def restart(server, _options)
      reset_server(server, "GracefulRestart")
    end

    def restart_now(server, _options)
      reset_server(server, "ForceRestart")
    end

    def restart_to_sys_setup(_args, _options)
      $redfish_log.error("Restarting to system setup is not supported.")
    end

    def restart_mgmt_controller(_server, _options)
      # TODO(tadeboro): This operation is not well defined, since server can
      # (and usually is) managed by more that one manager.
      $redfish_log.error("Restarting management controller is not supported.")
    end

    private

    def reset_server(server, reset_type)
      $redfish_log.info("Requesting #{reset_type} for #{server.ems_ref}.")
      with_provider_connection do |client|
        system = client.find(server.ems_ref)
        if system.nil?
          $redfish_log.error("#{server.ems_ref} does not exist anymore.")
          return
        end

        response = system.Actions["#ComputerSystem.Reset"].post(
          :field => "target", :payload => { "ResetType" => reset_type }
        )
        if [200, 202, 204].include?(response.status)
          $redfish_log.info("#{reset_type} for #{server.ems_ref} started.")
        else
          $redfish_log.error("#{reset_type} for #{server.ems_ref} failed.")
        end
      end
    end
  end
end
