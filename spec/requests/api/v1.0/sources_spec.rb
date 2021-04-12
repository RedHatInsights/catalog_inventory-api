require_relative "shared_examples_for_index"

RSpec.describe("v1.0 - Sources") do
  include ::Spec::Support::TenantIdentity

  let(:headers)         { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:attributes)      { {"tenant_id" => tenant.id.to_s} }
  let(:collection_path) { "/api/v1.0/sources" }

  include_examples(
    "v1x0_test_index_and_subcollections",
    "sources",
    [
      :service_instances,
      :service_inventories,
      :service_offerings,
      :service_offering_nodes,
      :service_plans,
    ],
  )
end
