class PersisterTaskService
  SERVICE_NAME = "platform.catalog.persister".freeze

  def initialize(options)
    @options = JSON.parse(options).deep_symbolize_keys

    validate_options
    @upload_task = Task.find(@options[:category])
    @source = Source.find(@upload_task.source_id)
  end

  def process
    return self unless @source.enabled

    case @upload_task.status
    when "error"
      errors = @upload_task.output["errors"].join("\; ")

      @source.update!(:refresh_state        => "Error",
                      :last_refresh_message => errors,
                      :refresh_finished_at  => Time.current)

      Rails.logger.error("Upload Task #{@upload_task.id} failed: #{errors}")
    when "unchanged"
      @source.update!(:refresh_state              => "Done",
                      :last_refresh_message       => "No changes detected, nothing uploaded from worker",
                      :refresh_finished_at        => Time.current,
                      :last_successful_refresh_at => @upload_task.updated_at)

      Rails.logger.info("No changes detected on source #{@source.id}, nothing uploaded from worker")
    else
      @task = FullRefreshPersisterTask.create!(opts)
      @upload_task.update!(:child_task_id => @task.id)
      @source.update!(:refresh_state => "Resyncing")

      Rails.logger.info("Upload Task #{@upload_task.id} now has persister child task #{@task.id}")

      topic = ClowderConfig.instance["kafkaTopics"][SERVICE_NAME] || SERVICE_NAME
      KafkaEventService.raise_event(topic, "persister", payload)
    end

    self
  end

  private

  def validate_options
    unless @options[:category].present? && @options[:url].present? && @options[:size].present?
      raise("Options must have category, url and size keys")
    end
  end

  def opts
    {}.tap do |options|
      options[:tenant_id] = @upload_task.tenant_id
      options[:source_id] = @upload_task.source_id
      options[:input] = input
      options[:state] = 'pending'
      options[:status] = 'ok'
    end
  end

  def input
    {}.tap do |options|
      options[:refresh_request_at] = @upload_task.created_at
      options[:data_url] = @options[:url]
      options[:size] = @options[:size]
    end
  end

  def payload
    input.merge!(:tenant_id => @upload_task.tenant_id, :source_id => @upload_task.source_id, :task_url => task_url)
  end

  def task_url
    host = ClowderConfig.instance["CATALOG_INVENTORY_INTERNAL_URL"]
    app_version = ClowderConfig.instance["CURRENT_API_VERSION"] || "v1.0"

    File.join(host, ClowderConfig.instance["PATH_PREFIX"], ClowderConfig.instance["APP_NAME"], app_version, "tasks", @task.id).gsub(/^\/+|\/+$/, "")
  end
end
