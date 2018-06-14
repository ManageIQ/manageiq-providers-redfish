module ManageIQ::Providers::Redfish
  class Inventory::Persister::PhysicalInfraManager < Inventory::Persister
    def initialize_inventory_collections
      collections = %i(
        physical_servers
        physical_server_details
        computer_systems
        hardwares
      )
      add_inventory_collections(physical_infra, collections)
    end
  end
end
