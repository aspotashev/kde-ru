class PosearchController < ApplicationController
  def index
  end

  def auto_complete_request
    search = params['search']['string'] if params['search']

    message_ids = IndexSearch.request(search.to_s, 10) # pairs (filename, index)
#    message_ids = message_ids.map {|id| [id[0], id[1]] }.flatten

    @msgs = message_ids.map do |id|
      PoMessageEntry.find_by_filename_and_index(id[0], id[1])
    end

    # These do not work:
    #@msgs = PoMessageEntry.find_by_filename_and_index(message_ids)
    #@msgs = PoMessageEntry.find_by_filename_and_index(['messages/kdeutils/ark.po', 'messages/kdeutils/filelight.po'], [8, 28])

    render :partial => 'search_results'
  end
end
