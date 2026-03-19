class MigrateExistingPhotosToPhotoModel < ActiveRecord::Migration[8.1]
  def up
    Tatoueur.find_each do |tatoueur|
      next unless tatoueur.photos.attached?

      tatoueur.photos.each_with_index do |attachment, i|
        photo = Photo.create!(
          record:   tatoueur,
          position: i
        )
        photo.image.attach(attachment.blob)
      end

      # Purge les anciennes photos has_many_attached
      tatoueur.photos.purge
    end
  end

  def down
    Photo.where(record_type: "Tatoueur").find_each do |photo|
      next unless photo.image.attached?
      tatoueur = Tatoueur.find_by(id: photo.record_id)
      tatoueur&.photos&.attach(photo.image.blob)
    end
    Photo.where(record_type: "Tatoueur").destroy_all
  end
end
