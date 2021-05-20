class IngressPayload < ApplicationRecord
  after_create_commit :check_pending_upload_tasks

  def check_pending_upload_tasks
    if Task.find(task_id).state == 'completed'
      Rails.logger.info("Task #{task_id} is completed, start persister task service")
      self.class.delete(id)

      PersisterTaskService.new(payload).process
    else
      Rails.logger.info("Ingress Kafka Message comes first")
    end
  end
end
