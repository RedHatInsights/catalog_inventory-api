require_relative "shared_examples_for_index"

RSpec.describe("v1.0 - Task") do
  include ::Spec::Support::TenantIdentity

  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }

  let(:attributes) do
    {
      "name"               => "name",
      "state"              => "pending",
      "status"             => "ok",
      "tenant_id"          => tenant.id.to_s
    }
  end

  include_examples(
    "v1x0_test_index_and_subcollections",
    "tasks",
    [],
  )

  context 'GET /tasks' do
    around do |example|
      with_modified_env(:CATALOG_INVENTORY_INTERNAL_URL => "http://inventory.example.com") do
        example.call
      end
    end

    before do
      source = Source.create!(:name => "foo", :tenant => tenant)
      FullRefreshUploadTask.create!(:tenant => tenant, :source => source, :state => "pending", :status => "ok")
      FullRefreshPersisterTask.create!(:tenant => tenant, :source => source, :state => "pending", :status => "ok")
    end

    it "list all tasks" do
      get "/api/catalog-inventory/v1.0/tasks", :headers => headers

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["data"].count).to eq(2)

      expect(JSON.parse(response.body)["data"].first["type"]).to eq("FullRefreshPersisterTask")
      expect(JSON.parse(response.body)["data"].second["type"]).to eq("FullRefreshUploadTask")
    end
  end
end
