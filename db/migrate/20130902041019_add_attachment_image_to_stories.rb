class AddAttachmentImageToStories < ActiveRecord::Migration
  def self.up
    change_table :stories do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :stories, :image
  end
end
