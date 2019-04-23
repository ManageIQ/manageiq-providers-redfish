describe ManageIQ::Providers::Redfish::PhysicalInfraManager::PhysicalServer do
  subject { FactoryBot.create(:redfish_physical_server, :vcr, :ext_management_system => ems) }

  let(:ems) { FactoryBot.create(:ems_redfish_physical_infra, :vcr) }

  it '.display_name' do
    expect(described_class).to receive(:n_).with('Physical Server (Redfish)', 'Physical Servers (Redfish)', 1)
    described_class.display_name
  end

  describe '#with_provider_object', :vcr do
    it 'yields correct system' do
      subject.with_provider_object do |system|
        expect(system).not_to be_nil
        expect(subject.ems_ref).to match(".+/#{system.Id}")
      end
    end
  end
end
