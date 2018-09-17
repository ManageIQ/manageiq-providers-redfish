module ManageIQ::Providers::Redfish::Inventory::Persister::Definitions::PhysicalInfraCollections
  include ActiveSupport::Concern

  def initialize_physical_infra_collections
    %i(
      physical_servers
      physical_server_details
      computer_systems
      hardwares
      physical_racks
    ).each do |name|
      add_collection(physical_infra, name)
    end
  end
end
