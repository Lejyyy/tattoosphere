class ChangeNullableFieldsOnEvents < ActiveRecord::Migration[7.0]
  def change
    change_column_null :events, :tatoueur_id, true
    change_column_null :events, :shop_id, true
  end
end