module ManageIQ::Providers::Redfish
  class Inventory::Collector::PhysicalInfraManager < Inventory::Collector
    def physical_servers
      rf_client.Systems.Members.collect(&:raw)
    end

    def physical_server_details
      rf_client.Systems.Members.collect { |s| get_server_location(s) }
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
  end
end
