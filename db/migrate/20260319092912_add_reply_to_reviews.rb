class AddReplyToReviews < ActiveRecord::Migration[8.1]
  def change
    add_column :reviews, :reply, :text
    add_column :reviews, :replied_at, :datetime
  end
end
