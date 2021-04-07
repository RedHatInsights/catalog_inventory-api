class AddSourceUpdatedAtAttribs < ActiveRecord::Migration[5.2]
  def change
    add_column :service_offerings, :source_updated_at, :datetime
    add_column :service_plans, :source_updated_at, :datetime
    add_column :service_credential_types, :source_updated_at, :datetime
  end
end
