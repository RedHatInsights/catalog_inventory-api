class FullRefreshPersisterTask < KafkaMessageTask
  after_update_commit :post_persister_task, :if => proc { state == 'completed' }

  @timeout_interval = 120 * 60 # 2 hours

  def post_persister_task
    PostPersisterTaskService.new(service_options).process
  end
end
