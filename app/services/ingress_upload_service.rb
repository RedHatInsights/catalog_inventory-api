class IngressUploadService
  def initialize(options)
    @options = JSON.parse(options).deep_symbolize_keys

    validate_options
    @task_id = @options[:category]
    @request_id = @options[:request_id]
  end

  def process
    payload = IngressPayload.create!(:task_id    => @task_id,
                                     :request_id => @request_id,
                                     :payload    => @options.to_json)

    Rails.logger.info("Payload record #{payload} is created")

    self
  end

  private

  def validate_options
    unless @options[:category].present? && @options[:url].present? && @options[:size].present?
      raise("Options must have category, url and size keys")
    end
  end
end
