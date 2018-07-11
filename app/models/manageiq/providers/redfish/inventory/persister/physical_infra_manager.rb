module ManageIQ::Providers::Redfish
  class Inventory::Persister::PhysicalInfraManager < Inventory::Persister
    include Inventory::Persister::Definitions::PhysicalInfraCollections

    def initialize_inventory_collections
      initialize_physical_infra_collections
    end
  end
end
