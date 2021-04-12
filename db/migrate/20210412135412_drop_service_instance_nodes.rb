class DropServiceInstanceNodes < ActiveRecord::Migration[5.2]
  def change
    drop_table :service_instance_node_service_credentials
    drop_table :service_instance_nodes
  end
end
