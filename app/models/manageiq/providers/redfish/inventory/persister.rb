module ManageIQ::Providers::Redfish
  class Inventory::Persister < ManagerRefresh::Inventory::Persister
    require_nested :PhysicalInfraManager

    protected

    def physical_infra
      InventoryCollectionDefault::PhysicalInfraManager
    end
  end
end
