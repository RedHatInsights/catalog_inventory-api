class FullRefreshPersisterTask < KafkaMessageTask
  after_update_commit :post_persister_task, :if => proc { state == 'completed' }

  @timeout_interval = 30 * 60 # 30 mins

  def post_persister_task
    PostPersisterTaskService.new(service_options).process
  end
end
