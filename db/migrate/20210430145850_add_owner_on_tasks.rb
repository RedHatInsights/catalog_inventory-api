class AddOwnerOnTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :owner, :string
  end
end
