module ManageIQ::Providers::Redfish
  class Inventory::Persister < ManageIQ::Providers::Inventory::Persister
    require_nested :PhysicalInfraManager
  end
end
