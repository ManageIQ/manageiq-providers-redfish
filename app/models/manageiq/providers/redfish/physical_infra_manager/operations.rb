module ManageIQ::Providers::Redfish
  module PhysicalInfraManager::Operations
    extend ActiveSupport::Concern

    include Power
    include Led
    include Firmware
  end
end
