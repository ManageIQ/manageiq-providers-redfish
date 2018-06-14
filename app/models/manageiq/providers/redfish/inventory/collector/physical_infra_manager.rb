module ManageIQ::Providers::Redfish
  class Inventory::Collector::PhysicalInfraManager < Inventory::Collector
    def physical_servers
      rf_client.Systems.Members.collect(&:raw)
    end

    def physical_server_details
      rf_client.Systems.Members.collect { |s| get_server_location(s) }
    end

    def hardwares
      rf_client.Systems.Members.collect { |s| get_server_hardware(s) }
    end

    private

    def get_server_location(server)
      loc = { :server_id => server["@odata.id"] }
      return loc if server.Links.Chassis.length.zero?

      chassis = [server.Links.Chassis.first]
      while chassis.last.Links.respond_to?("ContainedBy")
        chassis.push(chassis.last.Links.ContainedBy)
      end
      chassis.reduce(loc) do |acc, c|
        acc.merge!(c.respond_to?(:Location) ? c.Location.raw : {})
      end
    end

    def get_server_hardware(server)
      {
        :server_id => server["@odata.id"],
        :memory_mb => get_server_memory_mb(server),
        :cpu_cores => get_server_cpu_core_count(server),
        :capacity  => get_server_disk_capacity(server),
      }
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
  end
end
