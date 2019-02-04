class RenameStateToEntryTypeInUiLedgerReadModel < ActiveRecord::Migration[5.2]
  def change
    rename_column :ui_ledger_read_model, :state, :entry_type
  end
end
