describe ManageIQ::Providers::Redfish::PhysicalInfraManager do
  let(:server) { FactoryBot.create(:redfish_physical_server, :vcr) }
  subject(:ems) do
    FactoryBot.create(:ems_redfish_physical_infra, :vcr)
  end

  describe "#power_on", :vcr do
    it "powers on the system" do
      ems.power_on(server, nil)
    end
  end

  describe "#power_off", :vcr do
    it "powers off the system" do
      ems.power_off(server, nil)
    end
  end

  describe "#power_off_now", :vcr do
    it "powers off the system immediately" do
      ems.power_off_now(server, nil)
    end
  end

  describe "#restart", :vcr do
    it "restarts the system" do
      ems.restart(server, nil)
    end
  end

  describe "#restart_now", :vcr do
    it "restarts the system immediately" do
      ems.restart_now(server, nil)
    end
  end

  describe "#restart_to_sys_setup", :vcr do
    it "restarts to system setup" do
      ems.restart_to_sys_setup(server, nil)
    end
  end

  describe "#restart_mgmt_controller", :vcr do
    it "restarts management controller" do
      ems.restart_mgmt_controller(server, nil)
    end
  end
end
