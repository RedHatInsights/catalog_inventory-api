class LaunchJobTask < CloudConnectorTask
  SERVICE_NAME = "platform.catalog-inventory.task-output-stream".freeze

  after_update :post_launch_job_task, :if => proc { state == 'completed' }

  def post_launch_job_task
    topic = ClowderConfig.instance["kafkaTopics"][SERVICE_NAME] || SERVICE_NAME
    case status
    when 'ok'
      if tower_job_successful?
        PostLaunchJobTaskService.new(service_options).process
        KafkaEventService.raise_event(topic, "Task.update", payload, forwardable_headers)
      else
        self.status = 'error'
        self.message = output["description"] if output.present?
        save!

        Rails.logger.error("Task #{id} failed: #{output}")
      end
    when 'error'
      # called by above save!
      KafkaEventService.raise_event(topic, "Task.update", payload, forwardable_headers)
    else
      Rails.logger.error("LaunchJobTask #{id} has invalid status #{status}")
    end
  end

  def towing_tasks
    TowingTask.where(:child_task_id => id)
  end

  private

  def payload
    {}.tap do |options|
      options[:id] = id
      options[:status] = status
      options[:state] = state
      options[:source_id] = source.id
      options[:input] = input
      options[:output] = output
    end
  end

  def tower_job_successful?
    output.present? && output["status"] == "successful"
  end

  def service_options
    super.tap do |options|
      options[:service_offering_id] = service_offering.id.to_s
      options[:service_plan_id] = service_plan_id.to_s
      options[:external_url] = output["url"]
      options[:source_ref] = output["id"]
      options[:name] = output["name"]
      options[:source_created_at] = output["created"]
      options[:extra] = extra
    end.except(:task)
  end

  def extra
    {}.tap do |e|
      e[:status] = output["status"]
      e[:started] = output["started"]
      e[:finished] = output["finished"]
      e[:extra_vars] = output["extra_vars"]
      e[:artifacts] = output["artifacts"]
    end
  end

  def service_offering
    @service_offering ||= ServiceOffering.find_by(:source_ref => output["unified_job_template"].to_s) || raise("Unable to find ServiceOffering")
  end

  def service_plan_id
    # Not all service offerings have service plans
    service_offering.service_plans.first.try(:id)
  end
end
