module InitTypesEnvs
  # skip the initializer code if in travis build
  if ENV["SCHED_TASK"].blank? && ENV["TRAVIS"].blank? && ENV["RAILS_ENV"] && ENV["RAILS_ENV"] != "test"
    SOURCE_TYPE_NAME = "ansible-tower".freeze
    APPLICATION_TYPE_NAME = "/insights/platform/catalog".freeze

    source_types = Sources::Service.call do |api_instance|
      api_instance.list_source_types(:filter => {:name => SOURCE_TYPE_NAME})
    end

    application_types = Sources::Service.call do |api_instance|
      api_instance.list_application_types(:filter => {:name => APPLICATION_TYPE_NAME})
    end

    source_type_id = source_types.try(:data).try(:first).try(:id).to_i
    application_type_id = application_types.try(:data).try(:first).try(:id).to_i
    Rails.logger.info("Source Type ID #{source_type_id} Application_type_id #{application_type_id}")
    ClowderConfig.instance.merge!("SOURCE_TYPE_ID" => source_type_id, "APPLICATION_TYPE_ID" => application_type_id)
  end
end
