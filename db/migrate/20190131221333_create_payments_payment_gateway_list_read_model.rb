class CreatePaymentsPaymentGatewayListReadModel < ActiveRecord::Migration[5.2]
  def change
    create_table :payments_payment_gateway_list_read_model do |t|
      t.string  :identifier, null: false
      t.string  :adater,     null: false
      t.string  :fallback_identifier
      t.boolean :primary
    end
  end
end
