describe CheckAvailabilityTask do
  include ::Spec::Support::TenantIdentity

  let(:source) { Source.create!(:name => "source", :tenant => tenant) }
  let!(:task) { CheckAvailabilityTask.create!(:name => "task", :tenant => tenant, :source => source, :status => "ok", :state => state, :owner => "William") }
  let(:time_interval) { ClowderConfig.instance["CHECK_AVAILABILITY_TIMEOUT"] * 60 }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "before_update callback" do
    context "when task is timed out" do
      let(:state) { "timedout" }

      it "should raise an exception" do
        expect { task.update(:state => "completed") }.to raise_exception("Task #{task.id} was marked as timed out")
      end
    end

    context "when task is running" do
      let(:state) { "running" }

      it "should update" do
        expect(task).to receive(:post_check_availability_task)
        task.update(:state => "completed")
        expect(task.state).to eq("completed")
      end
    end
  end

  describe "#timed_out" do
    before { Timecop.safe_mode = true }

    context "when task is completed" do
      let(:state) { "completed" }

      it "returns false" do
        expect(task.timed_out?).to be_falsey
      end

      it "returns false" do
        Timecop.travel(Time.current + time_interval) do
          expect(task.timed_out?).to be_falsey
        end
      end
    end

    context "when task's state is not completed" do
      let(:state) { "running" }

      it "returns true" do
        Timecop.travel(Time.current + time_interval) do
          expect(task.timed_out?).to be_truthy
        end
      end

      it "returns false" do
        Timecop.travel(Time.current + 60) do
          expect(task.timed_out?).to be_falsey
        end
      end
    end
  end
end
