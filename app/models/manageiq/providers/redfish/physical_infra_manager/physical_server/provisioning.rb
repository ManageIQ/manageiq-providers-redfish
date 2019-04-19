module ManageIQ::Providers::Redfish
  module PhysicalInfraManager::PhysicalServer::Provisioning
    def deploy_pxe_config(pxe_image, customization_template)
      with_provider_object do |system|
        macs = mac_addresses(system)
        raise MiqException::MiqProvisionError, 'at least one MAC address is needed for provisioning' if macs.empty?
        macs.each { |mac| pxe_image.pxe_server.create_provisioning_files(pxe_image, mac, nil, customization_template) }
      end
    end

    def reboot_using_pxe
      with_provider_object do |system|
        response = system.patch(
          :payload => {
            'Boot' => {
              'BootSourceOverrideEnabled' => 'Once',
              'BootSourceOverrideTarget'  => 'Pxe'
            }
          }
        )
        raise MiqException::MiqProvisionError, "Cannot override boot order: #{response.data[:body]}" if response.status >= 400
      end
      # TODO: we perform force reboot which will fail in some cases. Need to handle with supports mixin.
      restart_now
    end

    def powered_on_now?
      # TODO(miha-plesko): we should rely on VMDB state instead contacting provider.
      # Update implementation once we have event-driven targeted refresh implemented.
      with_provider_object { |system| system.PowerState.to_s.downcase == 'on' }
    end

    private

    def mac_addresses(system)
      macs = system.EthernetInterfaces.Members
      (macs.map(&:MACAddress) + macs.map(&:PermanentMACAddress)).reject(&:blank?).uniq
    end
  end
end
