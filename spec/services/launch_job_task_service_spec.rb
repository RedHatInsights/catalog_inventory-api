describe LaunchJobTaskService do
  include ::Spec::Support::TenantIdentity

  let(:extra) { {"type" => "workflow_job_template"} }
  let(:service_offering) do
    FactoryBot.create(:service_offering, :tenant            => tenant,
                                         :source_ref        => '10',
                                         :extra             => extra,
                                         :source_id         => source.id,
                                         :service_inventory => service_inventory)
  end
  let(:source) { FactoryBot.create(:source, :tenant => tenant) }
  let(:service_inventory) { FactoryBot.create(:service_inventory, :tenant => tenant, :source_ref => '10') }

  let(:params) { {'service_offering_id' => service_offering.id} }
  let(:subject) { described_class.new(params) }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#process" do
    it "returns LaunchJobTask type of task" do
      task = subject.process.task

      expect(task.type).to eq('LaunchJobTask')
      expect(task.state).to eq('pending')
      expect(task.status).to eq('ok')
    end
  end
end
