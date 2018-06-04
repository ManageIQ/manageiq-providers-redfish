describe ManageIQ::Providers::Redfish::Inventory::Collector::PhysicalInfraManager do
  subject(:collector) { described_class.new(nil, nil) }

  context "#get_server_location" do
    it "returns only id on missing chassis" do
      server_data = {
        "@odata.id" => "sid",
        "Links"     => { "Chassis" => [] }
      }
      server = RedfishClient::Resource.new(nil, :content => server_data)
      expect(collector.send(:get_server_location, server))
        .to eq(:server_id => "sid")
    end

    it "retrieves chassis location" do
      chassis = {
        "Location" => { "key" => "value" },
        "Links"    => {}
      }
      server_data = {
        "@odata.id" => "sid",
        "Links"     => { "Chassis" => [chassis] }
      }
      server = RedfishClient::Resource.new(nil, :content => server_data)
      expect(collector.send(:get_server_location, server))
        .to eq(:server_id => "sid", "key" => "value")
    end

    it "merges all parent locations" do
      parent = {
        "Location" => { "a" => "parent" },
        "Links"    => {}
      }
      child = {
        "Location" => { "b" => "child" },
        "Links"    => { "ContainedBy" => parent }
      }
      server_data = {
        "@odata.id" => "sid",
        "Links"     => { "Chassis" => [child] }
      }
      server = RedfishClient::Resource.new(nil, :content => server_data)
      expect(collector.send(:get_server_location, server))
        .to eq(:server_id => "sid", "a" => "parent", "b" => "child")
    end
  end
end
