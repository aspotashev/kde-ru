class PoMessageEntry < ActiveRecord::Base
  # TODO: move this to the plugin, just call 'include' here

  set_table_name :po_messages

  establish_connection(IndexSearch.db_config)
end

