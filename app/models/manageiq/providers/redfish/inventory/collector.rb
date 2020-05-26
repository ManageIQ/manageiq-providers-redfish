module ManageIQ::Providers::Redfish
  class Inventory::Collector < ManageIQ::Providers::Inventory::Collector
    require_nested :PhysicalInfraManager
  end
end
