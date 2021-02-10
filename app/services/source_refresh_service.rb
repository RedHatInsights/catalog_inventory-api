class SourceRefreshService
  def initialize(source_id)
    @source = Source.find(source_id)
  end

  def process
    if @source.refresh_task_id.nil?
      dispatch_refresh_upload_task
    else
      task = Task.find(@source.refresh_task_id)

      if task.status == "error"
        dispatch_refresh_upload_task
        return self
      end

      if task.state == "completed"
        if task.child_task_id.nil?
          Rails.logger.error("PersisterTask is in creating, please try again later")
          raise CatalogInventory::Exceptions::RefreshAlreadyRunningException, "PersisterTask is in creating"
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
      FullRefreshUploadTaskService.new(options).process.task.dispatch
      @source.save!
    end
  rescue ActiveRecord::LockWaitTimeout
    Rails.logger.error("Source #{@source.id} is locked for updating, please try again later")
    raise CatalogInventory::Exceptions::RecordLockedException, "Source #{@source.id} is locked"
  end

  def options
    {:tenant_id => @source.tenant_id, :source_id => @source.id}
  end
end