module Events
  class KafkaListener
    attr_accessor :messaging_client_options, :service_name, :group_ref

    def initialize(messaging_client_options, service_name, group_ref)
      self.messaging_client_options = default_messaging_options.merge(messaging_client_options)
      self.service_name = service_name
      self.group_ref = group_ref
    end

    def run
      Thread.new { subscribe }
    end

    def subscribe
      ManageIQ::Messaging::Client.open(messaging_client_options) do |client|
        client.subscribe_topic(
          :service     => service_name,
          :persist_ref => group_ref,
          :max_bytes   => 500_000
        ) do |event|
          raw_process(event)
        end
      end
    rescue => e
      Rails.logger.error(["Something is wrong with Kafka client: ", e.message, *e.backtrace].join($RS))
      retry
    end

    private

    def raw_process(event)
      Rails.logger.info("Kafka message #{event.message} received with payload: #{event.payload}")

      insights_headers = event.headers.slice('x-rh-identity', 'x-rh-insights-request-id')

      # Kafka message from Ingress has no headers. We need to prepare the headers from its payload.
      if insights_headers.empty?
        if event.payload.instance_of?(Hash) && event.payload.key?("params") && event.payload["params"].key?("external_tenant")
          # check availability from source doesn't have headers
          insights_headers['x-rh-insights-request-id'] = "scheduled_task_#{Time.now.utc.to_s.tr(' ', '_')}"
          insights_headers['x-rh-identity'] = Headers::Service.x_rh_identity_tenant_user(event.payload["params"]["external_tenant"])
        else
          # ingress doesn't have any header
          header_hash = JSON.parse(event.payload)
          insights_headers['x-rh-insights-request-id'] = header_hash["request_id"]
          insights_headers['x-rh-identity'] = header_hash["b64_identity"]
        end
      end

      unless insights_headers['x-rh-identity'] && insights_headers['x-rh-insights-request-id']
        Rails.logger.debug("message skipped because of missing required headers")
        return
      end

      Insights::API::Common::Request.with_request(:headers => insights_headers, :original_url => nil) do |req|
        ActiveRecord::Base.connection_pool.with_connection do
          tenant = Tenant.find_or_create_by(:external_tenant => req.tenant)
          if tenant
            Rails.logger.debug("Tenant in KafkaListener: #{tenant.inspect}")
            Rails.logger.debug("Headers in KafkaListener: #{insights_headers}")

            ActsAsTenant.with_tenant(tenant) do            
              process_event(event)
            end
          else
            Rails.logger.error("Message skipped because it does not belong to a valid tenant")
          end
        end
      end
    rescue => e
      Rails.logger.error(["Error processing event: ", e.message, *e.backtrace].join($RS))
    ensure
      event.ack
    end

    def default_messaging_options
      {:protocol => :Kafka, :encoding => 'json'}
    end
  end
end
