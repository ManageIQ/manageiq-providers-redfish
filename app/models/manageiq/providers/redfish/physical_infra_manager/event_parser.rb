module ManageIQ::Providers::Redfish
  class PhysicalInfraManager::EventParser
    def self.event_to_hash(event, ems_id)
      {
        :ems_id     => ems_id,
        :ems_ref    => event["EventId"],
        :event_type => "redfish_#{event["MessageId"]}",
        :full_data  => event,
        :message    => event["Message"],
        :source     => "REDFISH",
        :timestamp  => event["EventTimestamp"] || Time.now.utc.to_s,
      }
    end
  end
end
