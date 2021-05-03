require_relative "shared_examples_for_index"

RSpec.describe("v1.0 - Task") do
  include ::Spec::Support::TenantIdentity

  let(:headers) { {"x-rh-identity" => identity} }

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
    []
  )

  context 'GET /tasks' do
    around do |example|
      with_modified_env(:CATALOG_INVENTORY_INTERNAL_URL => "http://inventory.example.com") do
        example.call
      end
    end

    before do
      source = Source.create!(:name => "foo", :tenant => tenant)
      @upload_task = FullRefreshUploadTask.create!(:tenant => tenant, :source => source, :state => "pending", :status => "ok", :owner => "jdoe")
      @persister_task = FullRefreshPersisterTask.create!(:tenant => tenant, :source => source, :state => "pending", :status => "ok", :owner => "jdoe")
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

  context 'PATCH /tasks/:id' do
    let(:valid_attributes) { {:message => "Successfully", :state => "running", :status => "ok"} }

    around do |example|
      with_modified_env(:CATALOG_INVENTORY_INTERNAL_URL => "http://inventory.example.com") do
        example.call
      end
    end

    before do
      source = Source.create!(:name => "foo", :tenant => tenant)
      @check_task = CheckAvailabilityTask.create!(:tenant => tenant, :source => source, :state => "pending", :status => "ok", :owner => 'system')
    end

    it "patch task" do
      patch "/api/catalog-inventory/v1.0/tasks/#{@check_task.id}", :headers => headers, :params => valid_attributes, :as => :json

      expect(response).to have_http_status(204)

      @check_task.reload
      expect(@check_task.message).to eq('Successfully')
      expect(@check_task.state).to eq('running')
      expect(@check_task.status).to eq('ok')
      expect(@check_task.owner).to eq('system')
    end
  end

  context 'create tasks' do
    let(:source) { Source.create!(:name => "foo", :tenant => tenant) }
    let(:default_identity) { encoded_user_hash(UserHeaderSpecHelper::DEFAULT_USER) }
    let(:cert_identity) { encoded_user_hash(UserHeaderSpecHelper::DEFAULT_CERT_USER) }
    let(:tenant_identity) { Headers::Service.x_rh_identity_tenant_user(rand(1000).to_s) }
    let(:admin_identity) { Headers::Service.x_rh_identity_dummy_admin }

    around do |example|
      Insights::API::Common::Request.with_request({:headers => headers, :original_url => 'https://example.com'}) do
        example.call
      end
    end

    context "with default headers" do
      let(:headers) { {'x-rh-identity' => default_identity} }

      it "create task" do
        @check_task = CheckAvailabilityTask.create!(:tenant => tenant, :source => source, :state => "pending", :status => "ok")

        expect(@check_task.owner).to eq('jdoe')
      end
    end

    context "with cert headers" do
      let(:headers) { {'x-rh-identity' => cert_identity} }

      it "create task" do
        @check_task = CheckAvailabilityTask.create!(:tenant => tenant, :source => source, :state => "pending", :status => "ok")

        expect(@check_task.owner).to eq('system')
      end
    end

    context "with tenant headers" do
      let(:headers) { {'x-rh-identity' => tenant_identity} }

      it "create task" do
        @check_task = CheckAvailabilityTask.create!(:tenant => tenant, :source => source, :state => "pending", :status => "ok")

        expect(@check_task.owner).to eq('system')
      end
    end

    context "with admin headers" do
      let(:headers) { {'x-rh-identity' => admin_identity} }

      it "create task" do
        @check_task = CheckAvailabilityTask.create!(:tenant => tenant, :source => source, :state => "pending", :status => "ok")

        expect(@check_task.owner).to eq('system')
      end
    end
  end
end
