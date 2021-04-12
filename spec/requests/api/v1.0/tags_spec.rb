require_relative "shared_examples_for_index"

RSpec.describe("v1.0 - Tag") do
  include ::Spec::Support::TenantIdentity

  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }

  let(:attributes) do
    {
      "tenant_id" => tenant.id.to_s,
      "tag"       => "/namespace/key=value"
    }
  end

  include_examples(
    "v1x0_test_index_and_subcollections",
    "tags",
    [
      :service_inventories
    ],
  )
end
