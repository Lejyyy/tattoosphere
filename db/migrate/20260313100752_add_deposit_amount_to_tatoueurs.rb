class AddDepositAmountToTatoueurs < ActiveRecord::Migration[8.1]
  def change
    add_column :tatoueurs, :deposit_amount, :decimal
  end
end
