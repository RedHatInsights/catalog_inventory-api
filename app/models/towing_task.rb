class TowingTask < LaunchJobTask
  after_update_commit :post_towing_task, :if => proc { state == 'completed' }

  def post_towing_task
    original_task = LaunchJobTask.find(child_task_id)

    if original_task.state != 'completed'
      update_task(original_task)
    end
  end

  def post_launch_job_task
  end

  private

  def update_task(task)
    task.with_lock("FOR UPDATE NOWAIT") do
      task.output = output
      task.state  = 'completed'
      task.status = 'ok'
      task.message = "Done by TowingTask #{id}"
      task.save!
    end
  rescue ActiveRecord::LockWaitTimeout
    Rails.logger.error("Task #{task.id} is locked for updating")
    raise CatalogInventory::Exceptions::RecordLockedException, "Task #{Task.id} is locked"
  end
end
