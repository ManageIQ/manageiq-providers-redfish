describe ManageIQ::Providers::Redfish::PhysicalInfraManager do
  let(:server) { FactoryBot.create(:redfish_physical_server, :vcr) }
  subject(:ems) do
    FactoryBot.create(:ems_redfish_physical_infra, :vcr)
  end

  describe "#blink_loc_led", :vcr do
    it "makes location LED start blinking" do
      ems.blink_loc_led(server, nil)
    end
  end

  describe "#turn_on_loc_led", :vcr do
    it "turns on location LED" do
      ems.turn_on_loc_led(server, nil)
    end
  end

  describe "#turn_off_loc_led", :vcr do
    it "turns off location LED" do
      ems.turn_off_loc_led(server, nil)
    end
  end
end
