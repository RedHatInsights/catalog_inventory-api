RSpec.describe Api::V1x0::ServicePlansController, :type => :request do
  it("Uses IndexMixin") { expect(described_class.instance_method(:index).owner).to eq(Api::V1x0::Mixins::IndexMixin) }
  it("Uses ShowMixin")  { expect(described_class.instance_method(:show).owner).to eq(Api::V1x0::Mixins::ShowMixin) }
end
