module ManageIQ::Providers::Redfish
  class Inventory::Persister::PhysicalInfraManager < Inventory::Persister
    def initialize_inventory_collections
      add_inventory_collections(physical_infra, %i(physical_servers))
    end
  end
end
