describe Source do
  include ::Spec::Support::TenantIdentity

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#source_ready?" do
    let(:source_instance) { Source.create!(:name => "source", :cloud_connector_id => id, :enabled => enabled, :tenant => tenant) }

    context "when application is ready" do
      let(:id) { "connector_id" }
      let(:enabled) { false }

      it "return true" do
        expect(source_instance).to receive(:dispatch_check_availability_task)
        source_instance.update!(:enabled => true)
        expect(source_instance.source_ready?).to be_truthy
      end
    end

    context "when application is ready, but enabled is true already" do
      let(:id) { "connector_id" }
      let(:enabled) { true }

      it "return false" do
        source_instance.update!(:enabled => true)
        expect(source_instance.source_ready?).to be_falsey
      end
    end

    context "when application is not ready" do
      let(:id) { nil }
      let(:enabled) { false }

      it "return false" do
        source_instance.update!(:enabled => true)
        expect(source_instance.source_ready?).to be_falsey
      end
    end
  end

  describe "#application_ready?" do
    let(:source_instance) { Source.create!(:name => "source", :cloud_connector_id => id, :enabled => enabled, :tenant => tenant) }

    context "when source is ready" do
      let(:id) { nil }
      let(:enabled) { true }

      it "return true" do
        expect(source_instance).to receive(:dispatch_check_availability_task)
        source_instance.update!(:cloud_connector_id => "connector_id")
        expect(source_instance.application_ready?).to be_truthy
      end
    end

    context "when source is ready, but cloud_connector_id is set" do
      let(:id) { "connector_id" }
      let(:enabled) { true }

      it "return true" do
        source_instance.update!(:cloud_connector_id => "new_connector_id")
        expect(source_instance.application_ready?).to be_falsey
      end
    end

    context "when source is not ready" do
      let(:id) { nil }
      let(:enabled) { false }

      it "return true" do
        source_instance.update!(:cloud_connector_id => "connector_id")
        expect(source_instance.application_ready?).to be_falsey
      end
    end
  end
end
