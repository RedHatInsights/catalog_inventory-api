require 'clowder-common-ruby'
require 'singleton'

class ClowderConfig
  include Singleton

  def self.instance
    @instance ||= {}.tap do |options|
      if ClowderCommonRuby::Config.clowder_enabled?
        config = ClowderCommonRuby::Config.load
        options["webPorts"] = config.webPort
        options["metricsPort"] = config.metricsPort
        options["metricsPath"] = config.metricsPath
        options["kafkaBrokers"] = [].tap do |brokers|
          config.kafka.brokers.each do |broker|
            brokers << "#{broker.hostname}:#{broker.port}"
          end
        end
        options["kafkaTopics"] = {}.tap do |topics|
          config.kafka.topics.each do |topic|
            topics[topic.requestedName] = topic.name
          end
        end
        options["endpoints"] = {}.tap do |endpoints|
          config.endpoints.each do |endpoint|
            endpoints["#{endpoint.app}-#{endpoint.name}"] = "http://#{endpoint.hostname}:#{endpoint.port}"
          end
        end
        options["databaseHostname"] = config.database.hostname
        options["databasePort"] = config.database.port
        options["databaseName"] = config.database.name
        options["databaseUsername"] = config.database.username
        options["databasePassword"] = config.database.password

        options["SOURCES_URL"] = exists("SOURCES_URL", options["endpoints"]["sources-api-svc"])
        options["CATALOG_INVENTORY_INTERNAL_URL"] = options["endpoints"]["catalog-inventory-api"]
      else
        options["webPorts"] = 3000
        options["metricsPort"] = 8080
        options["kafkaBrokers"] = ["#{ENV['QUEUE_HOST']}:#{ENV['QUEUE_PORT']}"]
        options["kafkaTopics"] = {}
        options["databaseHostname"] = ENV['DATABASE_HOST']
        options["databaseName"] = ENV['DATABASE_NAME']
        options["databasePort"] = ENV['DATABASE_PORT']
        options["databaseUsername"] = ENV['DATABASE_USER']
        options["databasePassword"] = ENV['DATABASE_PASSWORD']

        options["SOURCES_URL"] = exists("SOURCES_URL", ENV["SOURCES_URL"])
        options["CATALOG_INVENTORY_INTERNAL_URL"] = exists("CATALOG_INVENTORY_INTERNAL_URL", ENV["CATALOG_INVENTORY_INTERNAL_URL"])
      end

      options["APP_NAME"] = "catalog-inventory"
      options["PATH_PREFIX"] = "api"
      options["CLOUD_CONTROLLER_PSK"] = ENV['CLOUD_CONTROLLER_PSK']

      # TODO: update with valid url later
      options["CLOUD_CONNECTOR_URL"] = ENV["CLOUD_CONNECTOR_URL"] 
      options["UPLOAD_URL"] = ENV["UPLOAD_URL"]
      options["SOURCES_URL"] ||= ENV["SOURCES_URL"] 

      options["CATALOG_INVENTORY_EXTERNAL_URL"] = ENV["CATALOG_INVENTORY_EXTERNAL_URL"] || "Not Specified"
      options["SOURCE_REFRESH_TIMEOUT"] = ENV["SOURCE_REFRESH_TIMEOUT"] || 10 # in minutes
      options["INACTIVE_TASK_REMINDER_TIME"] = ENV["INACTIVE_TASK_REMINDER_TIME"] || 30 # in minutes
    end
  end

  def self.queue_host
    instance["kafkaBrokers"].first.split(":").first || "localhost"
  end

  def self.queue_port
    instance["kafkaBrokers"].first.split(":").last || "9092"
  end

  def self.exists(name, value)
    return value if value.present?

    Rails.logger.error("#{name} was not provided")
    return nil
  end
end

# ManageIQ Message Client depends on these variables
ENV["QUEUE_HOST"] = ClowderConfig.queue_host
ENV["QUEUE_PORT"] = ClowderConfig.queue_port
