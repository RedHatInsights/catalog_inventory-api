class CheckAvailabilityTask < CloudConnectorTask
  after_update :post_check_availability_task, :if => proc { state == 'completed' }

  def post_check_availability_task
    PostCheckAvailabilityTaskService.new(service_options).process
  end

  def service_options
    super.tap do |options|
      options[:task_id] = id
      options[:output] = output
    end
  end

  def dispatch
    super

    reload
    source.update!(:availability_message => "Message sent to RHC #{controller_message_id}") if status == 'ok'
  end
end
