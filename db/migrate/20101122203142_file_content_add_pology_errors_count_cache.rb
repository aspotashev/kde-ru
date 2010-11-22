class FileContentAddPologyErrorsCountCache < ActiveRecord::Migration
  def self.up
    # TODO: use a plugin for caching in DB (are the any plugins to do that)
    # See also db/migrate/20101122200806_file_content_add_pology_errors_cache.rb
    add_column :file_contents, :pology_errors_count_cache, :integer
  end

  def self.down
    remove_column :file_contents, :pology_errors_count_cache
  end
end
