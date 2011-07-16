class FileContentAddBranchId < ActiveRecord::Migration
  def self.up
    add_column :file_contents, :translation_branch_id, :integer, :default => -1
  end

  def self.down
    remove_column :file_contents, :translation_branch_id
  end
end
