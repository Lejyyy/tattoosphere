class AddBankDetailsToTatoueurs < ActiveRecord::Migration[8.1]
  def change
    add_column :tatoueurs, :iban, :string
    add_column :tatoueurs, :bic, :string
    add_column :tatoueurs, :bank_name, :string
  end
end
