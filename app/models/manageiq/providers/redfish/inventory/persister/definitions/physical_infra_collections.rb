module ManageIQ::Providers::Redfish::Inventory::Persister::Definitions::PhysicalInfraCollections
  include ActiveSupport::Concern

  def initialize_physical_infra_collections
    %i(
      physical_servers
      physical_server_details
      physical_server_computer_systems
      physical_server_hardwares
      physical_server_network_devices
      physical_server_storage_adapters

      physical_racks
      physical_chassis
      physical_chassis_details
    ).each do |name|
      add_collection(physical_infra, name)
    end
  end
end
