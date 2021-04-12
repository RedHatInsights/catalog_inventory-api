class Tenant < ApplicationRecord
  has_many :service_credentials
  has_many :service_credential_types
  has_many :service_instances
  has_many :service_instance_service_credentials
  has_many :service_inventories
  has_many :service_offerings
  has_many :service_offering_service_credentials
  has_many :service_offering_nodes
  has_many :service_offering_node_service_credentials
  has_many :service_offering_icons
  has_many :service_plans
  has_many :sources
  has_many :tags
  has_many :tasks
end
