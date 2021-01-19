require "manageiq-messaging"

RSpec.describe Api::V1x0::TasksController, :type => :request do
  it("Uses IndexMixin")   { expect(described_class.instance_method(:index).owner).to eq(Api::V1x0::Mixins::IndexMixin) }
  it("Uses ShowMixin")    { expect(described_class.instance_method(:show).owner).to eq(Api::V1x0::Mixins::ShowMixin) }

  include ::Spec::Support::TenantIdentity

  let(:headers) { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
  let(:client)  { instance_double("ManageIQ::Messaging::Client") }

  before do
    allow(CatalogInventory::Api::Messaging).to receive(:client).and_return(client)
    allow(client).to receive(:publish_topic)
  end

  it "patch /tasks/:id updates a Task" do
    task = Task.create!(:state => "running", :status => "ok", :input => { :message => "context1" }, :tenant => tenant)
    expect(client).to receive(:publish_topic).with(
      :service => "platform.catalog-inventory.task-output-stream",
      :event   => "Task.update",
      :payload => {"state" => "completed", "status" => "ok", "input" => { :message => "context2" }, "id" => task.id.to_s},
      :headers => {"x-rh-identity" => identity}
    )

    patch(api_v1x0_task_url(task.id), :params => {:state => "completed", :status => "ok", :input => { :message => "context2" }}.to_json, :headers => headers)

    expect(task.reload.state).to eq("completed")
    expect(task.reload.status).to eq("ok")
    expect(task.input).to eq("message" => "context2")

    expect(response.status).to eq(204)
    expect(response.parsed_body).to be_empty
  end
end
