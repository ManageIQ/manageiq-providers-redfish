describe ManageIQ::Providers::Redfish::PhysicalInfraManager::EventCatcher do
  it '.ems_class' do
    expect(described_class.ems_class)
      .to eq(ManageIQ::Providers::Redfish::PhysicalInfraManager)
  end

  it ".settings_name" do
    expect(described_class.settings_name).to eq(:event_catcher_redfish)
  end
end
