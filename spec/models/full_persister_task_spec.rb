describe FullRefreshPersisterTask do
  include ::Spec::Support::TenantIdentity

  let(:source) { Source.create!(:name => "source", :tenant => tenant) }
  let!(:task) do
    FullRefreshPersisterTask.create!(
      :name   => "task",
      :tenant => tenant,
      :source => source,
      :status => "ok",
      :state  => state,
      :owner  => "William"
    )
  end
  let(:tolerance) { 60 }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#timed_out" do
    before { Timecop.safe_mode = true }

    context "when task is timed out" do
      let(:state) { "timedout" }

      it "returns false" do
        expect(task.timed_out?).to be_falsey
      end

      it "returns false" do
        Timecop.travel(Time.current + FullRefreshPersisterTask.timeout_interval + tolerance) do
          expect(task.timed_out?).to be_falsey
        end
      end
    end

    context "when task's state is not completed" do
      let(:state) { "running" }

      it "returns true" do
        Timecop.travel(Time.current + FullRefreshPersisterTask.timeout_interval + tolerance) do
          expect(task.timed_out?).to be_truthy
        end
      end

      it "returns false" do
        Timecop.travel(Time.current + FullRefreshPersisterTask.timeout_interval - tolerance) do
          expect(task.timed_out?).to be_falsey
        end
      end
    end
  end
end
