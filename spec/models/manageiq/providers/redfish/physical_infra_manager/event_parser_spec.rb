describe ManageIQ::Providers::Redfish::PhysicalInfraManager::EventParser do
  let(:event) do
    {
      "Context"           => "context",
      "EventId"           => "8579",
      "EventTimestamp"    => "2018-09-19T12:25:27-0500",
      "EventType"         => "Alert",
      "MemberId"          => "32a734e0-bc29-11e8-8179-509a4c6c87ab",
      "Message"           => "System is turning off.",
      "MessageId"         => "SYS1001",
      "OriginOfCondition" => {
        "@odata.id" => "/redfish/v1/Systems/System-1-1-1-1"
      },
      "Severity"          => "Informational",
    }
  end

  context ".event_to_hash" do
    it "parses event data" do
      expect(described_class.event_to_hash(event, 1234)).to eq(
        :ems_id     => 1234,
        :ems_ref    => "8579",
        :event_type => "redfish_SYS1001",
        :full_data  => event,
        :message    => "System is turning off.",
        :source     => "REDFISH",
        :timestamp  => "2018-09-19T12:25:27-0500",
      )
    end
  end
end
