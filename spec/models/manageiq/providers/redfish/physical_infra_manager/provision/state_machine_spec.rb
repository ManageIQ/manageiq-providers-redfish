describe ManageIQ::Providers::Redfish::PhysicalInfraManager::Provision do
  before { EvmSpecHelper.create_guid_miq_server_zone }

  let(:server)    { FactoryBot.create(:physical_server) }
  let(:request)   { FactoryBot.create(:physical_server_provision_request) }
  let(:pxe_image) { FactoryBot.create(:pxe_image) }
  let(:template)  { FactoryBot.create(:customization_template) }

  subject { described_class.new(:source => server, :miq_request => request) }

  describe 'run state machine' do
    before { subject.update_attribute(:options, options) }
    before { allow(subject).to receive(:requeue_phase) { subject.send(subject.phase) } }
    before do
      allow(subject).to receive(:signal) do |method|
        subject.phase = method
        subject.send(method)
      end
    end

    context 'abort when missing pxe image' do
      let(:options) { { :pxe_image_id => 'missing' } }
      it do
        expect { subject.start_provisioning }.to raise_error(MiqException::MiqProvisionError)
      end
    end

    context 'abort when missing customization template' do
      let(:options) { { :customization_template_id => 'missing' } }
      it do
        expect { subject.start_provisioning }.to raise_error(MiqException::MiqProvisionError)
      end
    end

    context 'when all steps succeed' do
      let(:options) { { :pxe_image_id => pxe_image.id, :customization_template_id => template.id } }
      it do
        expect(server).to receive(:deploy_pxe_config).with(pxe_image, template)
        expect(server).to receive(:reboot_using_pxe)
        expect(server).to receive(:powered_on_now?).and_return(true)

        expect(subject).to receive(:done_provisioning)
        subject.start_provisioning
      end
    end

    context 'when all steps succeed after polling' do
      let(:options) { { :pxe_image_id => pxe_image.id, :customization_template_id => template.id } }
      it do
        expect(server).to receive(:deploy_pxe_config).with(pxe_image, template)
        expect(server).to receive(:reboot_using_pxe)
        expect(server).to receive(:powered_on_now?).and_return(false, false, true)

        expect(subject).to receive(:done_provisioning)
        subject.start_provisioning
      end
    end
  end
end
