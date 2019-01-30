class CreateVisaPaymentGatewayTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :visa_payment_gateway_transactions do |t|
      t.string  :identifier,        null: false
      t.string  :credit_card_token, null: false
      t.integer :amount,            null: false
      t.string  :currency,          null: false
      t.string  :state,             null: false
    end
  end
end
