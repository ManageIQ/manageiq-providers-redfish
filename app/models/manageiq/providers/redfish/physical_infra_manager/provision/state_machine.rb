module ManageIQ::Providers::Redfish::PhysicalInfraManager::Provision::StateMachine
  def start_provisioning
    update_and_notify_parent(:message => msg('start provisioning'))
    signal :deploy_pxe_config
  end

  def deploy_pxe_config
    update_and_notify_parent(:message => msg('deploy pxe config'))
    unless (pxe_image = PxeImage.find_by(:id => options[:pxe_image_id]))
      raise MiqException::MiqProvisionError, "PXE Image with id #{options[:pxe_image_id]} not found"
    end
    unless (template = CustomizationTemplate.find_by(:id => options[:customization_template_id]))
      raise MiqException::MiqProvisionError, "CustomizationTemplate with id #{options[:customization_template_id]} not found"
    end
    source.deploy_pxe_config(pxe_image, template)
    signal :reboot_using_pxe
  end

  def reboot_using_pxe
    update_and_notify_parent(:message => msg('reboot using PXE'))
    source.reboot_using_pxe
    signal :poll_server_running
  end

  def poll_server_running
    if source.powered_on_now?
      signal :done_provisioning
    else
      requeue_phase
    end
  end
end
