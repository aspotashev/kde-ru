class RemoveFileBranchings < ActiveRecord::Migration
  def self.up
    drop_table :file_branchings
  end

  def self.down
  end
end
