class IngressPayload < ApplicationRecord
  after_create_commit :check_pending_upload_tasks

  def check_pending_upload_tasks
    task = Task.find(task_id)
    Rails.logger.info("Task: #{task.id}, #{task.state}")

    if task.state == 'completed'
      Rails.logger.info("Task #{task_id} is completed, start persister task service")
      PersisterTaskService.new(payload).process

      self.class.delete(id)
    else
      Rails.logger.info("Ingress Kafka Message comes first")
    end
  end
end
