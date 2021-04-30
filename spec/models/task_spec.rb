describe Task do
  include ::Spec::Support::TenantIdentity

  let(:source) { Source.create!(:name => "source", :tenant => tenant) }
  let!(:task) { Task.create!(:name => "task", :tenant => tenant, :source => source, :status => "ok", :state => state, :owner => "William") }
  let(:time_interval) { ClowderConfig.instance["SOURCE_REFRESH_TIMEOUT"] * 60 }

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
