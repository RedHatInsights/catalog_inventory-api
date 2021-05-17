describe LaunchJobTask do
  include ::Spec::Support::TenantIdentity

  let(:source) { Source.create!(:name => "source1", :tenant => tenant) }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "before_update callback" do
    context "when task is timed out" do
      let(:launch_job_task) { LaunchJobTask.create!(:name => "task", :state => "timedout", :status => "ok", :tenant => tenant, :source => source) }

      it "should raise an exception" do
        expect { launch_job_task.update(:state => "completed") }.to raise_exception("Task #{launch_job_task.id} was marked as timed out")
      end
    end
  end

  describe "after_commit callback" do
    context "when LaunchJobTask has completed state" do
      let(:launch_job_task) { LaunchJobTask.create!(:name => "task", :state => "running", :status => "ok", :tenant => tenant, :source => source) }

      it "calls post_launch_job_task" do
        expect(launch_job_task).to receive(:post_launch_job_task)
        launch_job_task.update!(:state => 'completed')
      end
    end

    context "when LaunchJobTask's state is not completed" do
      let(:launch_job_task) { LaunchJobTask.create!(:name => "task", :state => "pending", :status => "ok", :tenant => tenant, :source => source) }

      it "no calls to post_launch_job_task" do
        expect(launch_job_task).to_not receive(:post_launch_job_task)

        launch_job_task.update!(:state => 'running')
      end
    end
  end

  describe "#post_launch_job_task" do
    let(:launch_job_task) do
      LaunchJobTask.create!(:name => "task", :state => "completed", :status => "ok", :tenant => tenant, :source => source, :output => output)
    end

    context "when LaunchJobTask's output has non-successful status" do
      let(:output) { {"description" => "Bad thing happened", "status" => "failed"} }

      it "run PostLaunchJobTaskService" do
        expect(KafkaEventService).to receive(:raise_event).once

        launch_job_task.post_launch_job_task

        launch_job_task.reload
        expect(launch_job_task.status).to eq("error")
        expect(launch_job_task.message).to eq("Bad thing happened")
      end
    end

    context "when LaunchJobTask's output has successful status" do
      let(:opts) { {"name" => "task name"} }
      let(:output) { {"status" => "successful"} }
      let(:service) { instance_double(PostLaunchJobTaskService) }

      before do
        allow(launch_job_task).to receive(:service_options).and_return(opts)
      end

      it "run PostLaunchJobTaskService" do
        expect(KafkaEventService).to receive(:raise_event).once
        expect(PostLaunchJobTaskService).to receive(:new).with(opts).and_return(service)
        expect(service).to receive(:process).and_return(service)

        launch_job_task.post_launch_job_task
      end
    end
  end
end
