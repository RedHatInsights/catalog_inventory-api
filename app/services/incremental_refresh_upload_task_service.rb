class IncrementalRefreshUploadTaskService < TaskService
  attr_reader :task

  def initialize(options)
    super
    @last_successful_refresh_at = @options[:last_successful_refresh_at]
  end

  def process
    @task = IncrementalRefreshUploadTask.create!(task_options)
    ActiveRecord::Base.connection.commit_db_transaction unless Rails.env.test?

    self
  end

  private

  def validate_options
    super
    raise("Options must have last_successful_refresh_at key") if @options[:last_successful_refresh_at].blank?
  end

  def response_format
    "tar"
  end

  def task_options
    {}.tap do |opts|
      opts[:tenant] = tenant
      opts[:source_id] = source_id
      opts[:state] = 'pending'
      opts[:status] = 'ok'
      opts[:forwardable_headers] = Insights::API::Common::Request.current_forwardable
      opts[:input] = task_input
    end
  end

  def tenant
    Tenant.find(@options[:tenant_id])
  end

  def jobs
    jobs = []
    jobs << templates_jobs
    jobs << credentials_jobs
    jobs << credential_types_jobs
    jobs << inventories_jobs
    jobs << workflow_templates_jobs
    jobs << workflow_template_nodes_jobs

    jobs.flatten
  end

  def templates_jobs
    [].tap do |templates_jobs|
      templates_jobs << CatalogInventory::Job.new.tap do |job|
        job.href_slug = "#{TOWER_API_VERSION}/job_templates?order=id&modified__gt=#{@last_successful_refresh_at}"
        job.method = "GET"
        job.fetch_all_pages = true
        job.apply_filter = "results[].{id:id, type:type, url:url,created:created,name:name, modified:modified, description:description,survey_spec:related.survey_spec,inventory:related.inventory,survey_enabled:survey_enabled,ask_tags_on_launch:ask_tags_on_launch,ask_limit_on_launch:ask_limit_on_launch,ask_job_type_on_launch:ask_job_type_on_launch,ask_diff_mode_on_launch:ask_diff_mode_on_launch,ask_inventory_on_launch:ask_inventory_on_launch,ask_skip_tags_on_launch:ask_skip_tags_on_launch,ask_variables_on_launch:ask_variables_on_launch,ask_verbosity_on_launch:ask_verbosity_on_launch,ask_credential_on_launch:ask_credential_on_launch}"
        job.fetch_related = fetch_related
      end

      templates_jobs << CatalogInventory::Job.new.tap do |job|
        job.href_slug = "#{TOWER_API_VERSION}/job_templates/?order=id"
        job.method = "GET"
        job.fetch_all_pages = true
        job.apply_filter = "results[].{id:id}"
        job.fetch_related = fetch_related
        job.page_prefix = "id"
      end
    end
  end

  def credentials_jobs
    [].tap do |credentials_jobs|
      credentials_jobs << CatalogInventory::Job.new.tap do |job|
        job.href_slug = "#{TOWER_API_VERSION}/credentials?order=id&modified__gt=#{@last_successful_refresh_at}"
        job.method = "GET"
        job.fetch_all_pages = true
        job.apply_filter = "results[].{id:id, type:type, created:created, name:name, modified:modified, description:description, credential_type:credential_type}"
      end

      credentials_jobs << CatalogInventory::Job.new.tap do |job|
        job.href_slug = "#{TOWER_API_VERSION}/credentials/?order=id"
        job.method = "GET"
        job.fetch_all_pages = true
        job.apply_filter = "results[].{id:id}"
        job.page_prefix = "id"
      end
    end
  end

  def credential_types_jobs
    [].tap do |credential_types_jobs|
      credential_types_jobs << CatalogInventory::Job.new.tap do |job|
        job.href_slug = "#{TOWER_API_VERSION}/credential_types?order=id&modified__gt=#{@last_successful_refresh_at}"
        job.method = "GET"
        job.fetch_all_pages = true
        job.apply_filter = "results[].{id:id, type:type, created:created, name:name, modified:modified, description:description, kind:kind, namespace:namespace}"
      end

      credential_types_jobs << CatalogInventory::Job.new.tap do |job|
        job.href_slug = "#{TOWER_API_VERSION}/credential_types/?order=id"
        job.method = "GET"
        job.fetch_all_pages = true
        job.apply_filter = "results[].{id:id}"
        job.page_prefix = "id"
      end
    end
  end

  def inventories_jobs
    [].tap do |inventories_jobs|
      inventories_jobs << CatalogInventory::Job.new.tap do |job|
        job.href_slug = "#{TOWER_API_VERSION}/inventories?order=id&modified__gt=#{@last_successful_refresh_at}"
        job.method = "GET"
        job.fetch_all_pages = true
        job.apply_filter = "results[].{id:id, type:type, created:created, name:name, modified:modified, description:description, kind:kind, type:type, variables:variables, host_filter:host_filter, pending_deletion:pending_deletion, organization:organization, inventory_sources_with_failures:inventory_sources_with_failures}"
      end

      inventories_jobs << CatalogInventory::Job.new.tap do |job|
        job.href_slug = "#{TOWER_API_VERSION}/inventories/?order=id"
        job.method = "GET"
        job.fetch_all_pages = true
        job.apply_filter = "results[].{id:id}"
        job.page_prefix = "id"
      end
    end
  end

  def workflow_templates_jobs
    [].tap do |workflow_templates_jobs|
      workflow_templates_jobs << CatalogInventory::Job.new.tap do |job|
        job.href_slug = "#{TOWER_API_VERSION}/workflow_job_templates?order=id&modified__gt=#{@last_successful_refresh_at}"
        job.method = "GET"
        job.fetch_all_pages = true
        job.apply_filter = "results[].{id:id, type:type, url:url,created:created, name:name, modified:modified, description:description, survey_spec:related.survey_spec, inventory:related.inventory, survey_enabled:survey_enabled, ask_inventory_on_launch:ask_inventory_on_launch, ask_variables_on_launch:ask_variables_on_launch}"
        job.fetch_related = fetch_related
      end

      workflow_templates_jobs << CatalogInventory::Job.new.tap do |job|
        job.href_slug = "#{TOWER_API_VERSION}/workflow_job_templates/?order=id"
        job.method = "GET"
        job.fetch_all_pages = true
        job.apply_filter = "results[].{id:id}"
        job.page_prefix = "id"
      end
    end
  end

  def workflow_template_nodes_jobs
    [].tap do |workflow_template_nodes_jobs|
      workflow_template_nodes_jobs << CatalogInventory::Job.new.tap do |job|
        job.href_slug = "#{TOWER_API_VERSION}/workflow_job_template_nodes?order=id&modified__gt=#{@last_successful_refresh_at}"
        job.method = "GET"
        job.fetch_all_pages = true
        job.apply_filter = "results[].{id:id, unified_job_type:summary_fields.unified_job_template.unified_job_type, inventory:inventory, type:type, url:url, created:created, modified:modified, workflow_job_template:workflow_job_template, unified_job_template:unified_job_template}"
      end

      workflow_template_nodes_jobs << CatalogInventory::Job.new.tap do |job|
        job.href_slug = "#{TOWER_API_VERSION}/workflow_job_template_nodes/?order=id"
        job.method = "GET"
        job.fetch_all_pages = true
        job.apply_filter = "results[].{id:id}"
        job.page_prefix = "id"
      end
    end
  end

  def upload_url
    ClowderConfig.instance["UPLOAD_URL"]
  end
end
