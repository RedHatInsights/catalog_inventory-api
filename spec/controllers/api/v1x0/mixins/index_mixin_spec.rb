describe Api::V1x0::Mixins::IndexMixin do
  describe Api::V1x0::SourcesController, :type => :request do
    include ::Spec::Support::TenantIdentity

    let(:headers)      { {"CONTENT_TYPE" => "application/json", "x-rh-identity" => identity} }
    let!(:source_1)    { Source.create!(:tenant => tenant, :uid => SecureRandom.uuid) }
    let!(:source_2)    { Source.create!(:tenant => tenant, :uid => SecureRandom.uuid) }

    it "Primary Collection: get /sources lists all Sources" do
      get(api_v1x0_sources_url, :headers => headers)

      expect(response.status).to eq(200)
      expect(response.parsed_body["data"]).to match([a_hash_including("id" => source_1.id.to_s), a_hash_including("id" => source_2.id.to_s)])
    end

    context "paging" do
      it "response_structure" do
        get(api_v1x0_sources_url, :headers => headers)

        expect(response.status).to eq(200)
        expect(response.parsed_body.keys).to eq(["meta", "links", "data"])
      end

      it "meta/count" do
        get(api_v1x0_sources_url, :headers => headers)

        expect(response.status).to eq(200)
        expect(response.parsed_body["meta"]).to eq("count" => 2, "limit" => 100, "offset" => 0)
      end
    end
  end
end
