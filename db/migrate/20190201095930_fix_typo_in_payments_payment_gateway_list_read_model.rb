class FixTypoInPaymentsPaymentGatewayListReadModel < ActiveRecord::Migration[5.2]
  def change
    rename_column :payments_payment_gateway_list_read_model, :adater, :adapter
  end
end
