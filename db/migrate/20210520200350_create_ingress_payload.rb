class CreateIngressPayload < ActiveRecord::Migration[5.2]
  def change
    create_table :ingress_payloads do |t|
      t.string :task_id
      t.string :request_id
      t.jsonb :payload

      t.timestamps
    end
  end
end
