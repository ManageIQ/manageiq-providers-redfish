module ManageIQ::Providers::Redfish
  class Inventory::Collector::PhysicalInfraManager < Inventory::Collector
    def physical_servers
      rf_client.Systems.Members
    end

    def physical_racks
      rf_client.Chassis.Members.select { |c| c.ChassisType == "Rack" }
    end
  end
end
