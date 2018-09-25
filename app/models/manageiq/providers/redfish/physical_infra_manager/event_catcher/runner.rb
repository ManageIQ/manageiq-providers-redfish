module ManageIQ::Providers::Redfish
  class PhysicalInfraManager::EventCatcher::Runner \
      < ManageIQ::Providers::BaseManager::EventCatcher::Runner
    def monitor_events
      event_stream.listen do |event|
        event_monitor_running
        @queue << event
      end
    end

    def stop_event_monitor
    end

    def queue_event(event)
      h = PhysicalInfraManager::EventParser.event_to_hash(event, @cfg[:ems_id])
      EmsEvent.add_queue("add", @cfg[:ems_id], h)
    end

    private

    def event_stream
      @event_stream ||= @ems.with_provider_connection(&:event_listener)
    end
  end
end
