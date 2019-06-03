module ManageIQ::Providers::Redfish::PhysicalInfraManager::Provision::StateMachine
  # This state machine does the following things:
  #
  #  1. Validate input parameters and configure components involved in the
  #     provisioning process (PXE server, computer system).
  #  2. Power cycle the computer system.
  #
  # Powering cycling the system is quite a complex operation, because it is
  # heavily dependent on the current state of the system. The worst case
  # scenario is when we get the system in PoweringOn state, since we need to
  # wait for it to finish the boot process, then power it down and start it
  # again. Steps taken in this worst-case scenario are:
  #
  #  1. Wait for server to transition into "On" state.
  #  2. Trigger power off.
  #  3. Wait for server to transition into "Off" state.
  #  4. Trigger power on.
  #  5. Wait for server to transition into "On" state.
  #
  # All other scenarios can be supported by simply skipping some of the
  # initial steps from this list.

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
    source.next_boot_using_pxe

    case power_state = source.power_state_now
    when "poweringon"  then signal :poll_server_on_initial
    when "on"          then signal :power_off_server
    when "poweringoff" then signal :poll_server_off
    when "off"         then signal :power_on_server
    else raise MiqException::MiqProvisionError, "Unexpected server power state: #{power_state}"
    end
  end

  def poll_server_on_initial
    if source.powered_on_now?
      signal :power_off_server
    else
      requeue_phase
    end
  end

  def power_off_server
    update_and_notify_parent(:message => msg('stop server'))
    source.power_down
    signal :poll_server_off
  end

  def poll_server_off
    if source.powered_off_now?
      signal :power_on_server
    else
      requeue_phase
    end
  end

  def power_on_server
    source.power_up
    signal :poll_server_on
  end

  def poll_server_on
    if source.powered_on_now?
      signal :done_provisioning
    else
      requeue_phase
    end
  end
end
