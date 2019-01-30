module UI
  module Ledger
    class Transaction < ActiveRecord::Base
      self.table_name = 'ui_ledger_read_model'
    end
  end
end
