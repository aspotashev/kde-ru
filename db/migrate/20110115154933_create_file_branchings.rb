class CreateFileBranchings < ActiveRecord::Migration
  def self.up
    create_table :file_branchings do |t|
      t.integer :translation_branch_id
      t.integer :translation_file_id
      t.integer :file_content_id

      t.timestamps
    end
  end

  def self.down
    drop_table :file_branchings
  end
end
