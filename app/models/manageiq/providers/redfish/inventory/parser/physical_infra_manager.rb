module ManageIQ::Providers::Redfish
  class Inventory::Parser::PhysicalInfraManager < Inventory::Parser
    def parse
      physical_servers
      physical_server_details
      hardwares
      physical_racks
    end

    private

    def physical_servers
      collector.physical_servers.each do |s|
        enclosure = s.dig("Links", "Chassis", 0, "@odata.id")
        rack = persister.physical_racks.lazy_find(enclosure) if enclosure

        server = persister.physical_servers.build(
          :ems_ref         => s["@odata.id"],
          :health_state    => s.Status.Health,
          :hostname        => s.HostName,
          :name            => s.Id,
          :physical_rack   => rack,
          :power_state     => s.PowerState,
          :raw_power_state => s.PowerState,
          :type            => "ManageIQ::Providers::Redfish::PhysicalInfraManager::PhysicalServer",
        )
        persister.computer_systems.build(:managed_entity => server)
      end
    end

    def physical_server_details
      collector.physical_servers.each do |s|
        server = persister.physical_servers.lazy_find(s["@odata.id"])
        location = get_server_location(s)
        persister.physical_server_details.build(
          :description        => s.Description,
          :location           => format_location(location),
          :location_led_state => s.IndicatorLED,
          :manufacturer       => s.Manufacturer,
          :model              => s.Model,
          :rack_name          => location.dig("Placement", "Rack"),
          :resource           => server,
          :serial_number      => s.SerialNumber,
        )
      end
    end

    def get_server_location(server)
      return {} if server.Links.Chassis.empty?

      chassis = [server.Links.Chassis.first]
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
        computer = persister.computer_systems.lazy_find(server)
        persister.hardwares.build(
          :computer_system => computer,
          :cpu_total_cores => get_server_cpu_core_count(s),
          :disk_capacity   => get_server_disk_capacity(s),
          :memory_mb       => get_server_memory_mb(s),
        )
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
  end
end
