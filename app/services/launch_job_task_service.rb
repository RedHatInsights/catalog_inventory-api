class LaunchJobTaskService < TaskService
  attr_reader :task

  def initialize(options)
    super
    @service_offering = ServiceOffering.find(@options[:service_offering_id])
  end

  def process
    @task = LaunchJobTask.create!(task_options)

    self
  end

  private

  def validate_options
    raise("Options must have service_offering_id key") if @options[:service_offering_id].blank?
  end

  def task_options
    {}.tap do |opts|
      opts[:forwardable_headers] = Insights::API::Common::Request.current_forwardable
      opts[:source_id] = source_id
      opts[:tenant] = tenant
      opts[:state]  = 'pending'
      opts[:status] = 'ok'
      opts[:input] = task_input
    end
  end

  def response_format
    "json"
  end

  def source_id
    @service_offering.source_id
  end

  def tenant
    @service_offering.tenant
  end

  def jobs
    jobs = []

    launch = CatalogInventory::Job.new
    launch.href_slug = href_slug
    launch.method = "launch"
    launch.params = payload_params
    launch.apply_filter = {"id":"id", "status":"status", "started":"started", "url":"url", "type":"type","finished":"finished", "modified":"modified", "description":"description", "extra_vars":"extra_vars", "artifacts":"artifacts", "name":"name","created":"created", "unified_job_template":"unified_job_template"}
    jobs << launch

    jobs
  end

  def href_slug
    if @service_offering.extra["type"] == "workflow_job_template"
      "#{TOWER_API_VERSION}/workflow_job_templates/#{@service_offering.source_ref}/launch/"
    else
      "#{TOWER_API_VERSION}/job_templates/#{@service_offering.source_ref}/launch/"
    end
  end

  def payload_params
    {:extra_vars => @options[:service_parameters] || {}}
  end
end
