class ServiceOfferingServiceCredential < ApplicationRecord
  belongs_to :service_credential
  belongs_to :service_offering
  belongs_to :tenant

  acts_as_tenant(:tenant)
end
