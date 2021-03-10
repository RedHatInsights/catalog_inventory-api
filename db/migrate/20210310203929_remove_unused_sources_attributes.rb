class RemoveUnusedSourcesAttributes < ActiveRecord::Migration[5.2]
  def change
    remove_column :sources, :bytes_received, :bigint
    remove_column :sources, :bytes_sent, :bigint
  end
end
