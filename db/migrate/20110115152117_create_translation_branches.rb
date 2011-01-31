class CreateTranslationBranches < ActiveRecord::Migration
  def self.up
    create_table :translation_branches do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :translation_branches
  end
end
