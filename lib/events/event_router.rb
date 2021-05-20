module Events
  class EventRouter
    def self.dispatch(event_type, payload)
      case event_type
      when "Catalog.upload"
        IngressUploadingService..new(payload).process
      when "Source.create"
        SourceCreateTaskService.new(payload).process
      when "Source.destroy"
        SourceDestroyTaskService.new(payload).process
      when "Application.create"
        ApplicationTaskService.new(payload.merge(:enabled => true)).process
      when "Application.destroy"
        ApplicationTaskService.new(payload.merge(:enabled => false)).process
      when "Source.availability_check"
        task = CheckAvailabilityTaskService.new(payload["params"]).process.task
        task.dispatch
      when "Endpoint.create"
        EndpointCreateTaskService.new(payload).process
      else
        Rails.logger.warn("Event type: #{event_type} is not supported.")
      end
    rescue => e
      Rails.logger.error("Failed to dispatch event [#{event_type}]: #{e.message}")
    end
  end
end
