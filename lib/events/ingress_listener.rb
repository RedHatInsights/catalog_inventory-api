module Events
  class IngressListener < KafkaListener
    SERVICE_NAME = "platform.upload.catalog".freeze
    GROUP_REF = "catalog_inventory-api".freeze

    def initialize(messaging_client_option)
      topic = ClowderConfig.instance["kafkaTopics"][SERVICE_NAME] || SERVICE_NAME
      super(messaging_client_option, topic, GROUP_REF)
    end

    private

    def process_event(event)
      EventRouter.dispatch("Catalog.upload", event.payload)
    end
  end
end
