require_relative "shared_examples_for_index"

RSpec.describe("v1.0 - Task") do
  include ::Spec::Support::TenantIdentity

  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }

  let(:attributes) do
    {
      "name"      => "name",
      "state"     => "pending",
      "status"    => "ok",
      "owner"     => "William",
      "tenant_id" => tenant.id.to_s
    }
  end

  include_examples(
    "v1x0_test_index_and_subcollections",
    "tasks",
    [],
  )

  context 'GET /tasks' do
    around do |example|
      Insights::API::Common::Request.with_request(default_request) do
        with_modified_env(:CATALOG_INVENTORY_INTERNAL_URL => "http://inventory.example.com") do
          example.call
        end
      end
    end

    before do
      source = Source.create!(:name => "foo", :tenant => tenant)
      @upload_task = FullRefreshUploadTask.create!(:tenant => tenant, :source => source, :state => "pending", :status => "ok")
      @persister_task = FullRefreshPersisterTask.create!(:tenant => tenant, :source => source, :state => "pending", :status => "ok")
    end

    it "with owner" do
      expect(@upload_task.owner).to eq('jdoe')
      expect(@persister_task.owner).to eq('jdoe')
    end

    it "list all tasks" do
      get "/api/catalog-inventory/v1.0/tasks", :headers => headers

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["data"].count).to eq(2)

      expect(JSON.parse(response.body)["data"].map { |x| x["type"] }).to match_array(["FullRefreshPersisterTask", "FullRefreshUploadTask"])
    end
  end
end
