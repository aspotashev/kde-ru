class CreateFileContents < ActiveRecord::Migration
  def self.up
    create_table :file_contents do |t|
      t.integer :user
      t.integer :translation_file

      t.timestamps
    end
  end

  def self.down
    drop_table :file_contents
  end
end
