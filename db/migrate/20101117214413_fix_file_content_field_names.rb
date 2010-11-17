class FixFileContentFieldNames < ActiveRecord::Migration
  def self.up
    rename_column :file_contents, :translation_file, :translation_file_id
    rename_column :file_contents, :user, :user_id
  end

  def self.down
    rename_column :file_contents, :translation_file_id, :translation_file
    rename_column :file_contents, :user_id, :user
  end
end
