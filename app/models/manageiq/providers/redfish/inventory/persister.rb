module ManageIQ::Providers::Redfish
  class Inventory::Persister < ManageIQ::Providers::Inventory::Persister
    require_nested :PhysicalInfraManager

    protected

    def targeted?
      false
    end

    def strategy
      nil
    end

    def parent
      manager.presence
    end

    def shared_options
      {
        :targeted => targeted?,
        :strategy => nil,
        :parent   => parent
      }
    end
  end
end
