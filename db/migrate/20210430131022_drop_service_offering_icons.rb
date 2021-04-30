class DropServiceOfferingIcons < ActiveRecord::Migration[5.2]
  def change
    remove_reference :service_offerings, :service_offering_icon
    drop_table :service_offering_icons
  end
end
