module ManageIQ::Providers::Redfish
  module PhysicalInfraManager::Operations::Led
    # Keep this in sync with app/models/physical_server/operations/led.rb in
    # core and IndicatorLED enum in Redfish ComputerSystem type. Name of the
    # method comes from the core and the action name used in the reset call
    # from the IndicatorLED enum.

    def blink_loc_led(server, _options)
      set_led_state("Blinking", server)
    end

    def turn_on_loc_led(server, _options)
      set_led_state("Lit", server)
    end

    def turn_off_loc_led(server, _options)
      set_led_state("Off", server)
    end

    private

    def set_led_state(state, server)
      $redfish_log.info("Setting #{server.ems_ref} LED state to #{state}.")
      with_provider_connection do |client|
        system = client.find(server.ems_ref)
        if system.nil?
          $redfish_log.error("#{server.ems_ref} does not exist anymore.")
          return
        end

        response = system.patch(:payload => { "IndicatorLED" => state })
        unless response.status == 200
          $redfish_log.error("LED state change on #{server.ems_ref} failed.")
        end
      end
    end
  end
end
