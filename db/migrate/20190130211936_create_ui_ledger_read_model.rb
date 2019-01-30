class CreateUiLedgerReadModel < ActiveRecord::Migration[5.2]
  def change
    create_table :ui_ledger_read_model do |t|
      t.string   :identifier, null: false
      t.string   :payment_gateway_transaction_identifier
      t.integer  :amount
      t.string   :currency
      t.datetime :timestamp
      t.string   :state
    end
  end
end
