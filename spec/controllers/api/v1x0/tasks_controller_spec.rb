require "manageiq-messaging"

RSpec.describe Api::V1x0::TasksController, :type => :request do
  it("Uses IndexMixin")   { expect(described_class.instance_method(:index).owner).to eq(Api::V1x0::Mixins::IndexMixin) }
  it("Uses ShowMixin")    { expect(described_class.instance_method(:show).owner).to eq(Api::V1x0::Mixins::ShowMixin) }

  include ::Spec::Support::TenantIdentity

  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:client)  { instance_double("ManageIQ::Messaging::Client") }
  let(:source) { Source.create!(:tenant => tenant) }
  let(:source_ref) { "10" }
  let!(:service_offering) { ServiceOffering.create!(:source => source, :tenant => tenant, "source_ref" => source_ref) }
  let(:output) { { "message" => "context1", "unified_job_template" => source_ref, "id" => "tower_job_id", "status" => "successful"} }

  before do
    allow(CatalogInventory::Api::Messaging).to receive(:client).and_return(client)
    allow(client).to receive(:publish_topic)
  end

  it "patch /tasks/:id updates a Task" do
    task = LaunchJobTask.create!(:state => "running", :status => "ok", :source => source, :tenant => tenant, :owner => "William")
    expect(client).to receive(:publish_topic).once

    patch(api_v1x0_task_url(task.id), :params => {:state => "completed", :status => "ok", :output => output}.to_json, :headers => headers)

    expect(task.reload.state).to eq("completed")
    expect(task.reload.status).to eq("ok")
    expect(task.output).to eq(output)

    expect(response.status).to eq(204)
    expect(response.parsed_body).to be_empty
  end
end
