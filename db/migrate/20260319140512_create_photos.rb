class CreatePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :photos do |t|
      t.references :record,       null: false, polymorphic: true
      t.references :tattoo_style, null: true,  foreign_key: true
      t.string     :title
      t.text       :description
      t.integer    :position,     null: false, default: 0
      t.timestamps
    end

    add_index :photos, [ :record_type, :record_id, :position ]
  end
end
