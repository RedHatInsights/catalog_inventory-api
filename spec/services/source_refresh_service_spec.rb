describe SourceRefreshService do
  include ::Spec::Support::TenantIdentity
  let(:subject) { described_class.new(source) }

  let!(:refresh_task) { FactoryBot.create(:task, :tenant => tenant, :created_at => Time.current, :state => state, :child_task_id => child_task_id) }
  let(:source) { FactoryBot.create(:source, :refresh_task_id => refresh_task_id, :enabled => true, :tenant => tenant) }
  let(:tolerance) { 2 * 60 * 60 } # 2 hrs

  around do |example|
    Insights::API::Common::Request.with_request(default_request) do |request|
      tenant = Tenant.find_or_create_by(:external_tenant => request.tenant)
      ActsAsTenant.with_tenant(tenant) { example.call }
    end
  end

  describe "#process" do
    context "when refresh task id is nil" do
      let(:refresh_task_id) { nil }
      let(:child_task_id) { nil }
      let(:state) { "running" }

      it "should create a refresh task" do
        expect(subject).to receive(:dispatch_refresh_upload_task)
        subject.process
      end
    end

    context "when refresh task id is invalid" do
      let(:refresh_task_id) { '123' }
      let(:child_task_id) { nil }
      let(:state) { "running" }

      it "should create a refresh task" do
        expect(subject).to receive(:dispatch_refresh_upload_task)
        expect(Rails.logger).to receive(:error).with(/^RefreshTask.+not found, may be deleted by a cronjob, will start a new refresh task$/)
        subject.process
      end
    end

    context "when refresh task is timed out" do
      before { Timecop.safe_mode = true }
      let(:refresh_task_id) { refresh_task.id }
      let(:child_task_id) { nil }
      let(:state) { "running" }

      it "should create a refresh task" do
        Timecop.travel(Time.current + tolerance) do
          expect(subject).to receive(:dispatch_refresh_upload_task)

          subject.process
          refresh_task.reload

          expect(refresh_task.state).to eq("timedout")
          expect(refresh_task.status).to eq("error")
        end
      end
    end

    context "when persister_task task is timed out" do
      let(:state) { "completed" }
      let(:persister_task) { FactoryBot.create(:task, :tenant => tenant, :created_at => Time.current) }
      let(:child_task_id) { persister_task.id }
      let(:refresh_task_id) { refresh_task.id }

      it "should create a refresh task" do
        Timecop.travel(Time.current + tolerance) do
          expect(subject).to receive(:dispatch_refresh_upload_task)
          expect(Rails.logger).to receive(:error).with(/^PersisterTask.+is timed out, start a new refresh task$/)

          subject.process
        end
      end
    end

    context "when persister_task task is deleted" do
      let(:state) { "completed" }
      let(:child_task_id) { "123" }
      let(:refresh_task_id) { refresh_task.id }

      it "should create a refresh task" do
        expect(subject).to receive(:dispatch_refresh_upload_task)
        expect(Rails.logger).to receive(:error).with(/^PersisterTask.+not found, may be deleted by a cronjob, will start a new refresh task$/)

        subject.process
      end
    end
  end
end
