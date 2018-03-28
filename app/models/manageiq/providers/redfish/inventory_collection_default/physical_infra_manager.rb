module ManageIQ::Providers::Redfish
  class InventoryCollectionDefault::PhysicalInfraManager \
      < ManagerRefresh::InventoryCollectionDefault::PhysicalInfraManager
    def self.physical_servers(extra_attributes = {})
      attributes = {
        :model_class                 => PhysicalInfraManager::PhysicalServer,
        :inventory_object_attributes => %i(
          type
          name
          health_state
          power_state
          hostname
          product_name
          manufacturer
          machine_type
          model
          serial_number
          field_replaceable_unit
          raw_power_state
          vendor
          location_led_state
          physical_rack_id
        )
      }
      super(attributes.merge(extra_attributes))
    end

    def self.physical_server_details(extra_attributes = {})
      attributes = {
        :inventory_object_attributes => %i(
          contact
          description
          location
          room
          rack_name
          lowest_rack_unit
        )
      }
      super(attributes.merge(extra_attributes))
    end

    def self.hardwares(extra_attributes = {})
      attributes = {
        :inventory_object_attributes => %i(
          disk_capacity
          memory_mb
          cpu_total_cores
        )
      }
      super(attributes.merge(extra_attributes))
    end
  end
end
