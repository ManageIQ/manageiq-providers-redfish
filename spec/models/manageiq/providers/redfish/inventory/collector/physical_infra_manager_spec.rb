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

  context "#get_server_hardware" do
    let(:server_data) do
      cpu_cores = [{ "TotalCores" => 3 }, { "TotalCores" => 2 }]
      devices = [{ "Devices" => [{ "CapacityBytes" => 123 }] }]
      drives = [
        { "Drives" => [{ "CapacityBytes" => 321 }] },
        { "Drives" => [{ "CapacityBytes" => 432 }] }
      ]
      {
        "@odata.id"     => "server_id",
        "MemorySummary" => { "TotalSystemMemoryGiB" => 3 },
        "Processors"    => { "Members" => cpu_cores },
        "SimpleStorage" => { "Members" => devices },
        "Storage"       => { "Members" => drives }
      }
    end
    let(:specs) do
      {
        :server_id => "server_id",
        :memory_mb => 3072,
        :cpu_cores => 5,
        :capacity  => 876
      }
    end

    it "sums up hardware specifications" do
      server = RedfishClient::Resource.new(nil, :content => server_data)
      expect(collector.send(:get_server_hardware, server)).to eq(specs)
    end
  end
end
