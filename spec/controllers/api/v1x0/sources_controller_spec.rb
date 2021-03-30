RSpec.describe Api::V1x0::SourcesController, :type => :request do
  it("Uses IndexMixin")   { expect(described_class.instance_method(:index).owner).to eq(Api::V1x0::Mixins::IndexMixin) }
  it("Uses ShowMixin")    { expect(described_class.instance_method(:show).owner).to eq(Api::V1x0::Mixins::ShowMixin) }

  include ::Spec::Support::TenantIdentity

  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:source_svc) { instance_double(SourceRefreshService) }
  let(:check_svc) { instance_double(CheckAvailabilityTaskService) }
  let(:source) { Source.create!(:tenant => tenant, :availability_status => status) }
  let(:task) { CheckAvailabilityTask.create }

  before do
    allow(source_svc).to receive(:process)
    allow(check_svc).to receive(:process).and_return(check_svc)
    allow(check_svc).to receive(:task).and_return(task)
  end

  describe "patch /sources/:id/refresh" do
    context "when source is available" do
      let(:status) { "available" }

      it "call SourceRefreshService" do
        expect(SourceRefreshService).to receive(:new).and_return(source_svc)
        patch "/api/catalog-inventory/v1.0/sources/#{source.id}/refresh", :headers => headers
        expect(response.status).to eq(204)
      end
    end

    context "when source is unavailable" do
      let(:status) { "unavailable" }

      it "call CheckAvailabilityTaskService" do
        expect(CheckAvailabilityTaskService).to receive(:new).and_return(check_svc)
        expect(task).to receive(:dispatch)

        patch "/api/catalog-inventory/v1.0/sources/#{source.id}/refresh", :headers => headers
        expect(response.status).to eq(204)
      end
    end
  end
end
