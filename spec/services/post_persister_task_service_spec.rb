describe PostPersisterTaskService do
  include ::Spec::Support::TenantIdentity

  let(:source) { FactoryBot.create(:source, :tenant => tenant) }
  let(:input) { { "refresh_request_at" => Time.current} }
  let(:status) { 'ok' }
  let(:task) { FactoryBot.create(:task, :source => source, :tenant => tenant, :input => input, :output => output, :status => status) }
  let!(:upload_task) { FactoryBot.create(:task, :source => source, :tenant => tenant, :output => upload_output, :created_at => Time.current, :child_task_id => task.id) }
  let(:upload_output) { {"sha256" => "abcd", "size" => 100} }
  let(:params) { {'source_id' => source.id, 'tenant_id' => tenant.id, 'task' => task} }
  let(:subject) { described_class.new(params) }
  let(:refresh_state) { "Done" }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  shared_examples_for "#process status ok" do
    it "should update the source object" do
      subject.process

      source.reload
      expect(source.last_refresh_message).to eq(last_refresh_message)
      expect(source.refresh_state).to eq(refresh_state)
    end
  end

  context "No updates" do
    let(:output) { {} }
    let(:last_refresh_message) { "No updates" }

    it_behaves_like "#process status ok"
  end

  context "Zeroed stats" do
    let(:stats) { {'service_plans' => {'adds' => 0, 'deletes' => 0}, 'creds' => {'adds' => 0, 'updates' => 0, 'deletes' => 0}}}
    let(:output) { {"stats" => stats} }
    let(:last_refresh_message) { "No updates" }

    it_behaves_like "#process status ok"
  end

  context "Show non zero values" do
    let(:stats) { {'service_plans' => {'adds' => 0, 'deletes' => 2}, 'creds' => {'adds' => 0, 'updates' => 0, 'deletes' => 0}, 'inventories' => {'adds' => 9}}}
    let(:output) { {"stats" => stats} }
    let(:last_refresh_message) { "service_plans: deletes=2\ninventories: adds=9"}

    it_behaves_like "#process status ok"
  end

  context "Show non zero values" do
    let(:status) { 'error' }
    let(:output) { {"errors" => ["kaboom","failed miserably"]} }
    let(:last_refresh_message) { "kaboom\nfailed miserably"}
    let(:refresh_state) { "Error" }

    it_behaves_like "#process status ok"
  end
end
