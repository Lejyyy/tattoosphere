class MigrateShopPhotosToPhotoModel < ActiveRecord::Migration[8.1]
  def up
    Shop.find_each do |shop|
      next unless shop.photos.attached?
      shop.photos.drop(1).each_with_index do |attachment, i|
        photo = Photo.create!(record: shop, position: i)
        photo.image.attach(attachment.blob)
      end
      shop.photos.drop(1).each(&:purge)
    end
  end

  def down
    Photo.where(record_type: "Shop").destroy_all
  end
end
