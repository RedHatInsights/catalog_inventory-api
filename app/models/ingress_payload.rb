class IngressPayload < ApplicationRecord
  after_create_commit :check_pending_upload_tasks

  def check_pending_upload_tasks
    task = Task.find(task_id)

    if task.state == 'completed'
      Rails.logger.debug("Payload record [#{self.inspect}] is deleted")
      self.class.delete(id)

      PersisterTaskService.new(payload).process
    else
      Rails.logger.info("Ingress Kafka Message comes first")
    end
  end
end
