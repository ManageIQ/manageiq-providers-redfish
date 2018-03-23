module ManageIQ::Providers::Redfish
  class Inventory::Collector < ManagerRefresh::Inventory::Collector
    require_nested :PhysicalInfraManager

    def rf_client
      @rf_client ||= manager.connect
    end
  end
end
