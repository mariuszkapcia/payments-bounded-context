class AddOrderNumberToUiLedgerReadModel < ActiveRecord::Migration[5.2]
  def up
    add_column :ui_ledger_read_model, :order_number, :string
    change_column :ui_ledger_read_model, :identifier, :string, null: true
  end

  def down
    remove_column :ui_ledger_read_model, :order_number, :string
    change_column :ui_ledger_read_model, :identifier, :string, null: false
  end
end
