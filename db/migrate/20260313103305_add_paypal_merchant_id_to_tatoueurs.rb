class AddPaypalMerchantIdToTatoueurs < ActiveRecord::Migration[8.1]
  def change
    add_column :tatoueurs, :paypal_merchant_id, :string
    add_column :tatoueurs, :paypal_onboarded, :boolean
  end
end
