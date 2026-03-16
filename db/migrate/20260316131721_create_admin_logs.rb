class CreateAdminLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_logs do |t|
      t.timestamps
    end
  end
end
