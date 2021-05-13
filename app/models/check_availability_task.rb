class CheckAvailabilityTask < CloudConnectorTask
  before_update :prevent_update, :if => proc { state_changed?(:from => 'timedout', :to => 'completed') }
  after_update :post_check_availability_task, :if => proc { state == 'completed' }

  @timeout_interval = ClowderConfig.instance["CHECK_AVAILABILITY_TIMEOUT"] * 60 # in seconds

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

  def prevent_update
    raise("Task #{id} was marked as timed out")
  end
end
