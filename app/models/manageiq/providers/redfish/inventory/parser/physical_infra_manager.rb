module ManageIQ::Providers::Redfish
  class Inventory::Parser::PhysicalInfraManager < Inventory::Parser
    def parse
      physical_servers
    end

    private

    def physical_servers
      collector.physical_servers.each do |s|
        server = persister.physical_servers.find_or_build(s["@odata.id"])
        server.assign_attributes(
          :type                   => "ManageIQ::Providers::Redfish::PhysicalInfraManager::PhysicalServer",
          :name                   => s["Id"],
          :health_state           => s["Status"]["Health"],
          :power_state            => s["PowerState"],
          :hostname               => s["HostName"],
          :product_name           => "dummy",
          :manufacturer           => s["Manufacturer"],
          :machine_type           => "dummy",
          :model                  => s["Model"],
          :serial_number          => s["SerialNumber"],
          :field_replaceable_unit => "dummy",
          :raw_power_state        => s["PowerState"],
          :vendor                 => "unknown",
          :location_led_state     => s["IndicatorLED"],
          :physical_rack_id       => 0
        )
      end
    end
  end
end
