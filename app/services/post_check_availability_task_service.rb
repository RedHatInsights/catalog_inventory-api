class PostCheckAvailabilityTaskService < TaskService
  SERVICE_NAME = "platform.sources.status".freeze
  STATUS_AVAILABLE, STATUS_UNAVAILABLE = %w[available unavailable].freeze

  def initialize(options)
    super
    @source = Source.find(@options[:source_id])
    @task   = @options[:task]
  end

  def process
    update_source
    topic = ClowderConfig.instance["kafkaTopics"][SERVICE_NAME] || SERVICE_NAME
    KafkaEventService.raise_event(topic, "availability_status", kafka_payload.to_json)
    @task.status == "ok" ? ok_services : Rails.logger.error("Task #{@task.id} failed")
    self
  end

  private

  def validate_options
    super
    raise("Options must have task key") if @options[:task].blank?
  end

  def ok_services
    TowingTaskService.new(:source_id => @source.id).process
    SourceRefreshService.new(@source).process
  end

  def update_source
    update_opts = {:availability_status => source_status, :last_checked_at => @task.created_at.iso8601}

    case @task.status
    when "ok"
      update_opts[:last_available_at] = @task.created_at.iso8601
      update_opts[:info] = @options[:output]
      update_opts[:availability_message] = 'Available'
    when "error"
      update_opts[:availability_message] = @task.output["errors"].join("\; ")
    end

    @source.update!(update_opts)
  end

  def kafka_payload
    {
      :resource_type => "Source",
      :resource_id   => @source.id,
      :status        => source_status
    }
  end

  def source_status
    @task.status == "ok" ? STATUS_AVAILABLE : STATUS_UNAVAILABLE
  end
end
