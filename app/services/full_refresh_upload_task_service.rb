class FullRefreshUploadTaskService < TaskService
  attr_reader :task

  def process
    unless @source.enabled
      Rails.logger.debug("Source #{source_id} is disabled")
      return self
    end

    @task = FullRefreshUploadTask.create!(task_options)
    ActiveRecord::Base.connection().commit_db_transaction unless Rails.env.test?

    self
  end

  private

  def response_format
    "tar"
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
    jobs << templates_job
    jobs << credentials_job
    jobs << credential_types_job
    jobs << inventories_job
    jobs << workflow_templates_job
    jobs << workflow_template_nodes_job

    jobs
  end

  def templates_job
    CatalogInventory::Job.new.tap do |job|
      job.href_slug = "#{TOWER_API_VERSION}/job_templates/?order=id"
      job.method = "GET"
      job.fetch_all_pages = true
      job.apply_filter = "results[].{id:id, type:type, url:url,created:created,name:name, modified:modified, description:description,survey_spec:related.survey_spec,inventory:related.inventory,survey_enabled:survey_enabled,ask_tags_on_launch:ask_tags_on_launch,ask_limit_on_launch:ask_limit_on_launch,ask_job_type_on_launch:ask_job_type_on_launch,ask_diff_mode_on_launch:ask_diff_mode_on_launch,ask_inventory_on_launch:ask_inventory_on_launch,ask_skip_tags_on_launch:ask_skip_tags_on_launch,ask_variables_on_launch:ask_variables_on_launch,ask_verbosity_on_launch:ask_verbosity_on_launch,ask_credential_on_launch:ask_credential_on_launch}"
      job.fetch_related = fetch_related
    end
  end

  def credentials_job
    CatalogInventory::Job.new.tap do |job|
      job.href_slug = "#{TOWER_API_VERSION}/credentials/?order=id"
      job.method = "GET"
      job.fetch_all_pages = true
      job.apply_filter = "results[].{id:id, type:type, created:created, name:name, modified:modified, description:description, credential_type:credential_type}"
    end
  end

  def credential_types_job
    CatalogInventory::Job.new.tap do |job|
      job.href_slug = "#{TOWER_API_VERSION}/credential_types/?order=id"
      job.method = "GET"
      job.fetch_all_pages = true
      job.apply_filter = "results[].{id:id, type:type, created:created, name:name, modified:modified, description:description, kind:kind, namespace:namespace}"
    end
  end

  def inventories_job
    CatalogInventory::Job.new.tap do |job|
      job.href_slug = "#{TOWER_API_VERSION}/inventories/?order=id"
      job.method = "GET"
      job.fetch_all_pages = true
      job.apply_filter = "results[].{id:id, type:type, created:created, name:name, modified:modified, description:description, kind:kind, type:type, variables:variables, host_filter:host_filter, pending_deletion:pending_deletion, organization:organization, inventory_sources_with_failures:inventory_sources_with_failures}"
    end
  end

  def workflow_templates_job
    CatalogInventory::Job.new.tap do |job|
      job.href_slug = "#{TOWER_API_VERSION}/workflow_job_templates/?order=id"
      job.method = "GET"
      job.fetch_all_pages = true
      job.apply_filter = "results[].{id:id, type:type, url:url,created:created, name:name, modified:modified, description:description, survey_spec:related.survey_spec, inventory:related.inventory, survey_enabled:survey_enabled, ask_inventory_on_launch:ask_inventory_on_launch, ask_variables_on_launch:ask_variables_on_launch}"
      job.fetch_related = fetch_related
    end
  end

  def workflow_template_nodes_job
    CatalogInventory::Job.new.tap do |job|
      job.href_slug = "#{TOWER_API_VERSION}/workflow_job_template_nodes/?order=id"
      job.method = "GET"
      job.fetch_all_pages = true
      job.apply_filter = "results[].{id:id, unified_job_type:summary_fields.unified_job_template.unified_job_type, inventory:inventory, type:type, url:url, created:created, modified:modified, workflow_job_template:workflow_job_template, unified_job_template:unified_job_template}"
    end
  end

  def upload_url
    ClowderConfig.instance["UPLOAD_URL"]
  end
end
