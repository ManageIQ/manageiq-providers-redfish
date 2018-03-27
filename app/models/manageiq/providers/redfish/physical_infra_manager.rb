module ManageIQ::Providers::Redfish
  class PhysicalInfraManager < ManageIQ::Providers::PhysicalInfraManager
    require_nested :Refresher
    require_nested :RefreshWorker

    include Vmdb::Logging
    include ManagerMixin

    has_many :physical_server_details,
             :class_name => "AssetDetail",
             :source     => :asset_detail,
             :through    => :physical_servers,
             :as         => :physical_server

    def self.ems_type
      @ems_type ||= "redfish_ph_infra".freeze
    end

    def self.description
      @description ||= "Redfish".freeze
    end
  end
end
