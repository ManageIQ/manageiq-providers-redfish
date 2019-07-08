module ManageIQ::Providers::Redfish
  class Inventory::Parser::PhysicalInfraManager < Inventory::Parser
    def parse
      physical_servers
      physical_server_details
      hardwares
      physical_racks
      physical_chassis
      physical_chassis_details
    end

    private

    def physical_servers
      collector.physical_servers.each do |s|
        parent_id = s.dig("Links", "Chassis", 0, "@odata.id")
        rack = persister.physical_racks.lazy_find(parent_id) if parent_id
        chassis = persister.physical_chassis.lazy_find(parent_id) if parent_id

        server = persister.physical_servers.build(
          :ems_ref          => s["@odata.id"],
          :health_state     => s.Status.Health,
          :hostname         => s.HostName,
          :name             => resource_name(s),
          :physical_chassis => chassis,
          :physical_rack    => rack,
          :power_state      => s.PowerState,
          :raw_power_state  => s.PowerState,
          :type             => "ManageIQ::Providers::Redfish::PhysicalInfraManager::PhysicalServer",
        )
        persister.physical_server_computer_systems.build(
          :managed_entity => server
        )
      end
    end

    def resource_name(res)
      parts = []
      parts << res.Manufacturer if res.Manufacturer
      parts << res.Name if res.Name
      parts << "(#{res.SerialNumber})" if res.SerialNumber
      parts.join(" ")
    end

    def physical_server_details
      collector.physical_servers.each do |s|
        server = persister.physical_servers.lazy_find(s["@odata.id"])
        location = get_server_location(s)
        persister.physical_server_details.build(
          :description        => s.Description,
          :location           => format_location(location),
          :location_led_state => s.IndicatorLED,
          :machine_type       => machine_type(s),
          :manufacturer       => s.Manufacturer,
          :model              => s.Model,
          :product_name       => s.Name,
          :rack_name          => location.dig("Placement", "Rack"),
          :resource           => server,
          :room               => location.dig("PostalAddress", "Room"),
          :serial_number      => s.SerialNumber,
        )
      end
    end

    def machine_type(server)
      server.Processors.Members.first.InstructionSet
    end

    def get_server_location(server)
      return {} if server.Links.Chassis.empty?
      get_chassis_location(server.Links.Chassis.first)
    end

    def get_chassis_location(chassis)
      chassis = [chassis]
      while chassis.last.Links.respond_to?("ContainedBy")
        chassis.push(chassis.last.Links.ContainedBy)
      end
      chassis.reduce({}) { |acc, c| acc.merge!(c.Location&.raw || {}) }
    end

    def format_location(location)
      %w(HouseNumber Street City Country).collect do |field|
        location.dig("PostalAddress", field)
      end.compact.join(", ")
    end

    def hardwares
      collector.physical_servers.each do |s|
        server = persister.physical_servers.lazy_find(s["@odata.id"])
        computer = persister.physical_server_computer_systems.lazy_find(server)
        hardware = persister.physical_server_hardwares.build(
          :computer_system => computer,
          :cpu_total_cores => get_server_cpu_core_count(s),
          :disk_capacity   => get_server_disk_capacity(s),
          :memory_mb       => get_server_memory_mb(s),
        )
        (s.NetworkInterfaces&.Members || []).each do |net_iface|
          net_adapter = net_iface.Links.NetworkAdapter
          persister.physical_server_network_devices.build(
            :hardware     => hardware,
            :device_name  => net_adapter.Name,
            :device_type  => "ethernet",
            :manufacturer => net_adapter.Manufacturer,
            :model        => net_adapter.Model,
            :uid_ems      => net_adapter["@odata.id"]
          )
        end
      end
    end

    def get_server_memory_mb(server)
      (server.MemorySummary&.TotalSystemMemoryGiB || 0) * 1024
    end

    def get_server_cpu_core_count(server)
      members = server.Processors&.Members || []
      members.reduce(0) { |acc, p| acc + (p.TotalCores || 0) }
    end

    def get_server_disk_capacity(server)
      get_simple_storage_sum(server) + get_storage_sum(server)
    end

    def get_simple_storage_sum(server)
      members = server.SimpleStorage&.Members || []
      members.reduce(0) { |acc, s| acc + get_simple_storage_capacity(s) }
    end

    def get_simple_storage_capacity(storage)
      storage.Devices.reduce(0) { |acc, d| acc + (d.CapacityBytes || 0) }
    end

    def get_storage_sum(server)
      members = server.Storage&.Members || []
      members.reduce(0) { |acc, s| acc + get_storage_capacity(s) }
    end

    def get_storage_capacity(storage)
      storage.Drives.reduce(0) { |acc, d| acc + (d.CapacityBytes || 0) }
    end

    def physical_racks
      collector.physical_racks.each do |r|
        persister.physical_racks.build(
          :ems_ref => r["@odata.id"],
          :name    => r.Id
        )
      end
    end

    def physical_chassis
      collector.physical_chassis.each do |c|
        parent_id = c.dig("Links", "ContainedBy", "@odata.id")
        chassis = persister.physical_chassis.lazy_find(parent_id) if parent_id
        rack = persister.physical_racks.lazy_find(parent_id) if parent_id

        persister.physical_chassis.build(
          :ems_ref                 => c["@odata.id"],
          :health_state            => c.Status.Health,
          :name                    => resource_name(c),
          :parent_physical_chassis => chassis,
          :physical_rack           => rack,
        )
      end
    end

    def physical_chassis_details
      collector.physical_chassis.each do |c|
        chassis = persister.physical_chassis.lazy_find(c["@odata.id"])
        location = get_chassis_location(c)
        persister.physical_chassis_details.build(
          :description        => c.Description,
          :location           => format_location(location),
          :location_led_state => c.IndicatorLED,
          :manufacturer       => c.Manufacturer,
          :model              => c.Model,
          :part_number        => c.PartNumber,
          :resource           => chassis,
          :serial_number      => c.SerialNumber,
        )
      end
    end
  end
end
