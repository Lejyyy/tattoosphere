class ChangeNullableFieldsOnSocials < ActiveRecord::Migration[7.0]
  def change
    change_column_null :socials, :tatoueur_id, true
    change_column_null :socials, :shop_id, true
  end
end