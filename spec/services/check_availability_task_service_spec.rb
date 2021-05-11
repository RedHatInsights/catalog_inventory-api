describe CheckAvailabilityTaskService do
  include ::Spec::Support::TenantIdentity

  let(:params) { {'external_tenant' => tenant.external_tenant, 'source_id' => source.id} }
  let(:subject) { described_class.new(params) }
  let(:time_interval) { ClowderConfig.instance["CHECK_AVAILABILITY_TIMEOUT"] * 60 }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#mark_timeout_if_needed" do
    let(:source) { FactoryBot.create(:source, :tenant => tenant, :cloud_connector_id => 'client_id', :enabled => true) }
    let!(:check_task) { CheckAvailabilityTask.create!(:tenant => tenant, :source_id => source.id, :state => 'pending', :status => 'ok') }

    before do
      allow(ClowderConfig).to receive(:instance).and_return({"SOURCES_URL" => "http://www.sources_url.com"})
      allow(ClowderConfig).to receive(:instance).and_return({"CHECK_AVAILABILITY_TIMEOUT" => 10})
    end

    context "when has a pending CheckAvailabilityTask" do
      before { Timecop.safe_mode = true }

      it "should mark the task timed out" do
        Timecop.travel(Time.current + time_interval) do
          subject.mark_timeout_if_needed

          check_task.reload
          source.reload
          expect(check_task.state).to eq('timedout')
          expect(check_task.status).to eq('error')
          expect(source.availability_status).to eq('unavailable')
        end
      end
    end

    context "when check availability task is not timed out" do
      it "should mark the task timed out" do
        subject.mark_timeout_if_needed

        expect(check_task.state).to eq('pending')
        expect(check_task.status).to eq('ok')
      end
    end
  end

  describe "#process" do
    before do
      allow(ClowderConfig).to receive(:instance).and_return({"SOURCES_URL" => "http://www.sources_url.com"})
    end

    context "when source is ready for availability check" do
      let(:source) { FactoryBot.create(:source, :tenant => tenant, :cloud_connector_id => 'client_id', :enabled => true) }

      it "returns CheckAvailabilityTask type of task" do
        task = subject.process.task

        expect(task.type).to eq('CheckAvailabilityTask')
        expect(task.input["response_format"]).to eq('json')
        expect(task.input["jobs"]).to eq([{"apply_filter"=>{"version"=>"version"}, "href_slug"=>"api/v2/config/", "method"=>"get"}])
        expect(task.input["upload_url"]).to be_nil
        expect(task.state).to eq('pending')
        expect(task.status).to eq('ok')
        expect(task.owner).to eq('jdoe')
      end
    end

    context "when source is only enabled" do
      let(:source) { FactoryBot.create(:source, :tenant => tenant, :enabled => true) }

      it "raises an error" do
        expect{ subject.process.task }.to raise_error(StandardError, /not ready for availability_check!/)
      end
    end

    context "when source is disabled" do
      let(:source) { FactoryBot.create(:source, :tenant => tenant, :enabled => false) }

      it "raises an error" do
        expect{ subject.process.task }.to raise_error(StandardError, /not ready for availability_check!/)
      end
    end
  end
end
