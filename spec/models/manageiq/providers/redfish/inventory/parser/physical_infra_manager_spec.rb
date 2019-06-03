describe ManageIQ::Providers::Redfish::Inventory::Parser::PhysicalInfraManager do
  def new_resource(content)
    RedfishClient::Resource.new(nil, :raw => content)
  end

  subject(:parser) { described_class.new }

  context "#get_server_location" do
    it "returns empty hash on missing chassis" do
      server = new_resource(
        "@odata.id" => "sid",
        "Links"     => { "Chassis" => [] }
      )
      expect(parser.send(:get_server_location, server)).to eq({})
    end

    it "retrieves chassis location" do
      server = new_resource(
        "@odata.id" => "sid",
        "Links"     => {
          "Chassis" => [
            {
              "Location" => { "key" => "value" },
              "Links"    => {}
            }
          ]
        }
      )
      expect(parser.send(:get_server_location, server)).to eq("key" => "value")
    end

    it "merges all parent locations" do
      server = new_resource(
        "@odata.id" => "sid",
        "Links"     => {
          "Chassis" => [
            {
              "Location" => { "b" => "child" },
              "Links"    => {
                "ContainedBy" => {
                  "Location" => { "a" => "parent" },
                  "Links"    => {}
                }
              }
            }
          ]
        }
      )
      expect(parser.send(:get_server_location, server)).to eq("a" => "parent",
                                                              "b" => "child")
    end
  end
end
