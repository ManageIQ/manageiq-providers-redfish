module ManageIQ::Providers::Redfish
  class Builder
    def self.build_inventory(ems, target)
      Inventory.new(
        Inventory::Persister::PhysicalInfraManager.new(ems, target),
        Inventory::Collector::PhysicalInfraManager.new(ems, target),
        Inventory::Parser::PhysicalInfraManager.new
      )
    end
  end
end
