module ManageIQ::Providers::Redfish
  class Inventory::Parser < ManagerRefresh::Inventory::Parser
    require_nested :PhysicalInfraManager
  end
end
