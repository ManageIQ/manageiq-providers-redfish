module ManageIQ::Providers::Redfish
  class PhysicalInfraManager < ManageIQ::Providers::PhysicalInfraManager
    require_nested :EventCatcher
    require_nested :EventParser
    require_nested :Refresher
    require_nested :RefreshWorker
    require_nested :PhysicalServer

    include Vmdb::Logging
    include ManagerMixin
    include Operations

    supports :create

    def self.ems_type
      @ems_type ||= "redfish_ph_infra".freeze
    end

    def self.description
      @description ||= "Redfish".freeze
    end
  end
end
