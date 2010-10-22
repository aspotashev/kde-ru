class CreateTranslationFiles < ActiveRecord::Migration
  def self.up
    create_table :translation_files do |t|
      t.string :filename_with_path
      t.integer :moved_to # id of another TranslationFile,
			  # -1 means that it was not moved,
			  # -2 means that the file was removed

      t.timestamps
    end
  end

  def self.down
    drop_table :translation_files
  end
end
