module ManageIQ::Providers::Redfish
  class Inventory::Parser::PhysicalInfraManager < Inventory::Parser
    def parse
      physical_servers
      physical_server_details
      hardwares
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
        )
        persister.computer_systems.build(:managed_entity => server)
      end
    end

    def physical_server_details
      # TODO(tadeboro): There is no similar data in Redfish service, so
      # mapping will need to be quite sophisticated if we would like to get
      # more info into database.
      collector.physical_server_details.each do |d|
        server = persister.physical_servers.lazy_find(d[:server_id])
        persister.physical_server_details.build(
          :resource           => server,
          :contact            => "",
          :description        => "",
          :location           => get_location(d),
          :room               => "",
          :rack_name          => get_rack(d),
          :location_led_state => d["IndicatorLED"],
          :lowest_rack_unit   => ""
        )
      end
    end

    def get_location(detail)
      [
        detail.dig("PostalAddress", "HouseNumber"),
        detail.dig("PostalAddress", "Street"),
        detail.dig("PostalAddress", "City"),
        detail.dig("PostalAddress", "Country")
      ].compact.join(", ")
    end

    def get_rack(detail)
      detail.dig("Placement", "Rack") || ""
    end

    def hardwares
      collector.hardwares.each do |h|
        server = persister.physical_servers.find_or_build(h[:server_id])
        computer = persister.computer_systems.find_or_build(server)
        hardware = persister.hardwares.find_or_build(computer)
        hardware.assign_attributes(
          :disk_capacity   => h[:capacity],
          :memory_mb       => h[:memory_mb],
          :cpu_total_cores => h[:cpu_cores]
        )
      end
    end
  end
end
