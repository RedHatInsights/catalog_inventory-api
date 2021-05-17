class SourceCreateTaskService < TaskService
  def process
    return if ClowderConfig.instance["SOURCE_TYPE_ID"] != @options[:source_type_id]

    Rails.logger.info("Creating Source")
    Rails.logger.info("Tenant: #{tenant.inspect}")

    Source.create!(source_options)
    Rails.logger.info("Creating Source Finished")
  end

  private

  def source_options
    {}.tap do |options|
      options[:id] = @options[:id]
      options[:uid] = @options[:uid]
      options[:name] = @options[:name]
    end
  end

  def validate_options
    raise("Options must have id") unless @options[:id].present?
    raise("Options must have uid") unless @options[:uid].present?
    raise("Options must have name") unless @options[:name].present?
  end
end
