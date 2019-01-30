class AddPaymentGatewayIdentifierToUiLedgerReadModel < ActiveRecord::Migration[5.2]
  def change
    add_column :ui_ledger_read_model, :payment_gateway_identifier, :string
  end
end
