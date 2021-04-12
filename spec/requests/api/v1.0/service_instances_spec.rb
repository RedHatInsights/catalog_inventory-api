require_relative "shared_examples_for_index"

RSpec.describe("v1.0 - ServiceInstance") do
  include ::Spec::Support::TenantIdentity

  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:source) { Source.create!(:tenant => tenant) }
  let(:service_offering) { ServiceOffering.create!("source_id" => source.id, "tenant_id" => tenant.id, "source_ref" => SecureRandom.uuid,) }
  let(:service_plan) { ServicePlan.create!("source_id" => source.id, "tenant_id" => tenant.id, "service_offering_id" => service_offering.id, "source_ref" => SecureRandom.uuid,) }

  let(:attributes) do
    {
      "source_id"           => source.id.to_s,
      "tenant_id"           => tenant.id.to_s,
      "service_offering_id" => service_offering.id.to_s,
      "service_plan_id"     => service_plan.id.to_s,
      "source_ref"          => SecureRandom.uuid,
    }
  end

  include_examples(
    "v1x0_test_index_and_subcollections",
    "service_instances",
    ["service_credentials"],
  )
end
