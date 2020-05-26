module ManageIQ::Providers::Redfish
  class Inventory::Collector::PhysicalInfraManager < Inventory::Collector
    def collect
      physical_servers
      physical_racks
      physical_chassis
      firmware_inventory
    ensure
      disconnect!
    end

    def physical_servers
      @physical_servers ||= connection.Systems.Members
    end

    def physical_racks
      @physical_racks ||= connection.Chassis.Members.select { |c| c.ChassisType == "Rack" }
    end

    def physical_chassis
      @physical_chassis ||= connection.Chassis.Members.reject { |c| c.ChassisType == "Rack" }
    end

    def firmware_inventory
      @firmware_inventory ||= connection.UpdateService.FirmwareInventory&.Members || []
    end

    private

    def connection
      @connection ||= manager.connect
    end

    def disconnect!
      @connection&.logout
    rescue => error
      $redfish_log.warn("Disconnect failed: #{error}")
    end
  end
end
