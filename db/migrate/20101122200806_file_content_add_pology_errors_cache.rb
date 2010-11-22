class FileContentAddPologyErrorsCache < ActiveRecord::Migration
  def self.up
    # TODO: use a plugin for caching in DB (are the any plugins to do that)
    add_column :file_contents, :pology_errors_cache, :text
  end

  def self.down
    remove_column :file_contents, :pology_errors_cache
  end
end
