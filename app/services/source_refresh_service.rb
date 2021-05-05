class SourceRefreshService
  def initialize(source, allow_incr_refresh = false)
    @source = source
    @allow_incr_refresh = allow_incr_refresh
  end

  def process
    if @source.refresh_task_id.nil?
      dispatch_refresh_upload_task
    else
      task = Task.find(@source.refresh_task_id)

      if ["error", "unchanged"].include?(task.status)
        dispatch_refresh_upload_task
        return self
      end

      if task.timed_out?
        task.update!(:state => "timedout", :status => "error", :output => {"errors" => ["Timed out"]})
        dispatch_refresh_upload_task
        return self
      end

      if task.state == "completed"
        if task.child_task_id.nil?
          Rails.logger.error("Waiting for payload, please try again later")
          raise CatalogInventory::Exceptions::RefreshAlreadyRunningException, "Waiting for payload"
        end

        persister_task = Task.find(task.child_task_id)

        if persister_task.state == "completed"
          dispatch_refresh_upload_task
        else
          Rails.logger.error("PersisterTask #{persister_task.id} is running, please try again later")
          raise CatalogInventory::Exceptions::RefreshAlreadyRunningException, "PersisterTask #{persister_task.id} is running"
        end
      else
        Rails.logger.error("Uploading Task #{task.id} is running, please try again later")
        raise CatalogInventory::Exceptions::RefreshAlreadyRunningException, "UploadTask #{task.id} is running"
      end
    end

    self
  end

  private

  def dispatch_refresh_upload_task
    @source.with_lock("FOR UPDATE NOWAIT") do
      create_refresh_upload_task
      @source.save!
    end
  rescue ActiveRecord::LockWaitTimeout
    Rails.logger.error("Source #{@source.id} is locked for updating, please try again later")
    raise CatalogInventory::Exceptions::RecordLockedException, "Source #{@source.id} is locked"
  end

  def create_refresh_upload_task
    opts = {:tenant_id => @source.tenant_id, :source_id => @source.id}

    upload_task = if @source.last_successful_refresh_at.present? && @allow_incr_refresh
                    IncrementalRefreshUploadTaskService.new(opts.merge!(:last_successful_refresh_at => @source.last_successful_refresh_at.iso8601)).process.task
                  else
                    FullRefreshUploadTaskService.new(opts).process.task
                  end

    upload_task.dispatch
  end
end
