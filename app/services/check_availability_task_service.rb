class CheckAvailabilityTaskService < TaskService
  attr_reader :task

  def process
    raise "Source #{source_id} does not exist" unless @source

    refresh unless @source.ready_for_check?

    @task = CheckAvailabilityTask.create!(task_options)
    ActiveRecord::Base.connection().commit_db_transaction unless Rails.env.test?
    self
  rescue => e
    Rails.logger.error("Failed to create task: #{e.message}")
    raise
  end

  private

  def refresh
    endpoints = Sources::Service.call do |api_instance|
      api_instance.list_endpoints(:filter => {:source_id => source_id})
    end
    endpoint = endpoints.try(:data).try(:first)

    applications = Sources::Service.call do |api_instance|
      api_instance.list_applications(:filter => {
                                       :source_id           => source_id,
                                       :application_type_id => ClowderConfig.instance["APPLICATION_TYPE_ID"]
                                     })
    end

    raise("Source #{source_id} is not ready for availability_check!") if endpoint.blank? || applications.data.empty?

    Source.update(source_id, :cloud_connector_id => endpoint.receptor_node, :enabled => true)
  end

  def response_format
    "json"
  end

  def task_options
    {}.tap do |options|
      options[:tenant] = tenant
      options[:source_id] = source_id
      options[:state] = 'pending'
      options[:status] = 'ok'
      options[:forwardable_headers] = Insights::API::Common::Request.current_forwardable
      options[:input] = task_input
    end
  end

  def jobs
    jobs = []

    check_availability_job = CatalogInventory::Job.new
    check_availability_job.href_slug = "api/v2/config/"
    check_availability_job.method = "get"
    check_availability_job.apply_filter = {"version":"version"}
    jobs << check_availability_job

    jobs
  end
end
