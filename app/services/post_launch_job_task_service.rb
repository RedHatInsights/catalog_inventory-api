class PostLaunchJobTaskService < TaskService
  def process
    create_service_instance

    self
  end

  private

  def validate_options
    raise("Options must have source_ref key") if @options[:source_ref].blank?
  end

  def create_service_instance
    instance = ServiceInstance.create(@options)
    Rails.logger.info("ServiceInstance##{instance.id} is created.")
  end
end
