module ManageIQ::Providers::Redfish
  class PhysicalInfraManager < ManageIQ::Providers::PhysicalInfraManager
    include Vmdb::Logging
    include ManagerMixin

    def self.ems_type
      @ems_type ||= "redfish_ph_infra".freeze
    end

    def self.description
      @description ||= "Redfish".freeze
    end
  end
end
