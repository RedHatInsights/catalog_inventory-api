describe PersisterTaskService do
  include ::Spec::Support::TenantIdentity

  let(:params) { JSON({'url' => 'http://example.com', 'size' => 1000, 'category' => task.id}) }
  let(:task) { FactoryBot.create(:task, :source => source, :tenant => tenant) }
  let(:subject) { described_class.new(params) }

  around do |example|
    Insights::API::Common::Request.with_request(default_request) { example.call }
  end

  describe "#process" do
    context "when source is enabled" do
      before { ClowderConfig.instance["CATALOG_INVENTORY_INTERNAL_URL"] = 'url' }
      after { ClowderConfig.instance["CATALOG_INVENTORY_INTERNAL_URL"] = nil }
      let(:source) { FactoryBot.create(:source, :enabled => true, :tenant => tenant) }

      it "should create a FullRefreshPersisterTask" do
        expect(CatalogInventory::Api::Messaging.client).to receive(:publish_topic)

        subject.process

        expect(Task.where(:type => "FullRefreshPersisterTask").count).to eq(1)
      end
    end

    context "when source is enabled" do
      let(:source) { FactoryBot.create(:source, :enabled => false, :tenant => tenant) }

      it "should not create a FullRefreshPersisterTask" do
        expect(CatalogInventory::Api::Messaging.client).not_to receive(:publish_topic)

        subject.process

        expect(Task.where(:type => "FullRefreshPersisterTask").count).to eq(0)
      end
    end

    context "when task status is error" do
      let(:source) { FactoryBot.create(:source, :enabled => true, :tenant => tenant) }
      let(:task) { FactoryBot.create(:task, :source => source, :tenant => tenant, :status => 'error', :output => errors) }
      let(:errors) { {"errors" => ["something", "wrong"]} }

      it "should return source" do
        subject.process
        source.reload

        expect(source.refresh_state).to eq("Error")
        expect(source.last_refresh_message).to eq("something; wrong")
      end
    end

    context "when task status is unchanged" do
      let(:source) { FactoryBot.create(:source, :enabled => true, :tenant => tenant) }
      let(:task) { FactoryBot.create(:task, :source => source, :tenant => tenant, :status => 'unchanged') }

      it "should return source" do
        subject.process
        source.reload

        expect(source.refresh_state).to eq("Done")
        expect(source.last_refresh_message).to eq("No changes detected, nothing uploaded from worker")
      end
    end
  end
end
