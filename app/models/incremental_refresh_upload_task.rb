class IncrementalRefreshUploadTask < CloudConnectorTask
  after_update_commit :post_upload_task, :if => proc { saved_change_to_state?(:to => 'completed') && ['unchanged', 'error', 'ok'].include?(status) }

  @timeout_interval = ClowderConfig.instance["SOURCE_REFRESH_TIMEOUT"] * 60 # in seconds

  def post_upload_task
    PostUploadTaskService.new(service_options).process
  end

  def dispatch
    super

    reload
    if status == 'ok'
      source.update!(:refresh_started_at   => Time.current,
                     :refresh_finished_at  => nil,
                     :refresh_task_id      => id,
                     :last_refresh_message => "Message sent to RHC #{controller_message_id}",
                     :refresh_state        => "Uploading")

      Rails.logger.info("Source #{source.id} set refresh task id to #{id}")
    end
  end
end
