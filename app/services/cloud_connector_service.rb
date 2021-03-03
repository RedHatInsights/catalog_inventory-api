require 'net/http'
require 'uri'
require 'json'

class CloudConnectorService
  API_VERSION = "v1".freeze
  DIRECTIVE = "catalog".freeze
  VALID_STATUS_CODES = %w[200 201 202].freeze
  def initialize(options)
    @options = options.deep_symbolize_keys

    validate_options
    @task_id  = @options[:task_id]
    @task_url = @options[:task_url]
    @cloud_connector_id = @options[:cloud_connector_id]
    @cloud_connector_url = @options[:cloud_connector_url]
    @task = Task.find(@task_id)
  end

  def process
    Rails.logger.info("publish: #{payload}")
    send_to_cloud_controller
  end

  private

  def send_to_cloud_controller
    account = @task.tenant.external_tenant

    cc_url = File.join(@cloud_connector_url, API_VERSION, "message")
    body = {'account':   account,
            'recipient': @cloud_connector_id,
            'directive': DIRECTIVE,
            'payload':   payload}
    uri = URI.parse(cc_url)

    header = {'Content-Type': 'application/json'}.merge(Insights::API::Common::Request.current_forwardable)
    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = body.to_json

    # Send the request
    response = http.request(request)
    Rails.logger.info("Sent message for #{@cloud_connector_id} #{response.code} #{response.message}")

    VALID_STATUS_CODES.include?(response.code) ? @task.update!(:controller_message_id => JSON.parse(response.body)['id']) : task_failed(response.body)
  rescue => error
    task_failed(error)
  end

  def task_failed(error)
    Rails.logger.error("Error sending message to cloud controller node id: #{@cloud_connector_id} #{error}")
    @task.update_attributes(:state => "completed", :status => "error", :output => {'errors' => ["#{error}"]} )
  end

  def validate_options
    unless @options[:task_id].present? && @options[:task_url].present? && @options[:cloud_connector_url].present? && @options[:cloud_connector_id].present?
      raise("Options must have task_id, task_url, cloud_connector_url and cloud_connector_id keys")
    end
  end

  def payload
    {"URL" => "#{@task_url}/#{@task_id}"}
  end
end
