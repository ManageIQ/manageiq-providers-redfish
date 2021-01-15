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
      trigger_first_valid_power_action(server, %w[On])
    end

    def power_off(server, _options)
      trigger_first_valid_power_action(server, %w[GracefulShutdown])
    end

    def power_off_now(server, _options)
      trigger_first_valid_power_action(server, %w[ForceOff])
    end

    def restart(server, _options)
      trigger_first_valid_power_action(server, %w[GracefulRestart])
    end

    def restart_now(server, _options)
      trigger_first_valid_power_action(server, %w[ForceRestart])
    end

    def restart_to_sys_setup(_args, _options)
      _log.error("Restarting to system setup is not supported.")
      raise MiqException::Error, "Restarting to system setup is not supported."
    end

    def restart_mgmt_controller(_server, _options)
      # TODO(tadeboro): This operation is not well defined, since server can
      # (and usually is) managed by more that one manager.
      _log.error("Restarting BMC is not supported.")
      raise MiqException::Error, "Restarting BMC is not supported."
    end

    # Select any supported method of powering the server down.
    def power_down(server, _options)
      trigger_first_valid_power_action(server, %w[ForceOff GracefulShutdown])
    end

    # Select any supported method of powering the server up.
    def power_up(server, _options)
      trigger_first_valid_power_action(server, %w[On ForceOn])
    end

    private

    def trigger_first_valid_power_action(server, rtypes)
      server.with_provider_object do |system|
        available_rtypes = get_available_rtypes(system)
        rtype = rtypes.find { |t| available_rtypes.include?(t) }
        if rtype.nil?
          _log.error("#{rtypes} and #{available_rtypes} are disjunct.")
          raise MiqException::Error, "No acceptable reset type"
        end

        execute_reset_action(system, rtype)
      end
    end

    def get_available_rtypes(system)
      action = system.Actions["#ComputerSystem.Reset"]
      get_inline_rtypes(action) || get_action_info_rtypes(action) || []
    end

    def get_inline_rtypes(action)
      action["ResetType@Redfish.AllowableValues"]
    end

    def get_action_info_rtypes(action)
      params = action["@Redfish.ActionInfo"]&.Parameters || []
      params.find { |p| p.Name == "ResetType" }&.AllowableValues
    end

    def execute_reset_action(system, rtype)
      _log.info("Attempting to execute #{rtype} reset.")
      response = system.Actions["#ComputerSystem.Reset"].post(
        :field => "target", :payload => { "ResetType" => rtype }
      )
      unless [200, 202, 204].include?(response.status)
        raise MiqException::Error, "'#{rtype}' reset failed: #{response.body}."
      end

      _log.info("#{rtype} reset done.")
      response
    end
  end
end
