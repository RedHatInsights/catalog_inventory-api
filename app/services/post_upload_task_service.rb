class PostUploadTaskService < TaskService
  def process
    ingress_payload = IngressPayload.find_by(:task_id => @options[:task].id)

    if ingress_payload.present?
      ingress_payload.check_pending_upload_tasks
    else
      Rails.logger.info("Upload task comes first")
    end

    update_source
    self
  end

  private

  def validate_options
    super
    raise("Options must have task key") if @options[:task].blank?
  end

  def update_source
    case @options[:task].status
    when "unchanged"
      @source.update!(unchanged_options)
    when "ok"
      @source.update!(ok_options)
    when "error"
      @source.update!(error_options)
    else
      Rails.logger.warn("#{@options[:tasks]} is unhandled")
    end

    Rails.logger.info("Source #{@source.id}: refresh finished at #{@source.refresh_finished_at}, state: #{@source.refresh_state}, message: #{@source.last_refresh_message}")
  end

  def unchanged_options
    {:refresh_finished_at        => Time.current,
     :last_refresh_message       => @options[:task].message,
     :last_successful_refresh_at => @options[:task].created_at,
     :refresh_state              => "Done"}
  end

  def ok_options
    {:refresh_finished_at  => Time.current,
     :last_refresh_message => "Asking persister to commit changes to Database",
     :refresh_state        => "Resyncing"}
  end

  def error_options
    {:refresh_finished_at  => Time.current,
     :last_refresh_message => @options[:task][:output]["errors"].join("\n"),
     :refresh_state        => "Error"}
  end
end
