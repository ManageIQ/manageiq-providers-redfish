module ManageIQ::Providers::Redfish
  class Inventory::Parser < ManageIQ::Providers::Inventory::Parser
    require_nested :PhysicalInfraManager
  end
end
