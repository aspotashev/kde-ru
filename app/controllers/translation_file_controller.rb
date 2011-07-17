class TranslationFileController < ApplicationController
#  before_filter :login_required

  def index
    @file = TranslationFile.find(params[:id])
  end

  def polist
    @category_list = {}
    TranslationFile.find(:all, :conditions => ['NOT filename_with_path LIKE ?', '<DUMP>']).
      map(&:filename_with_path).map {|x| x.sub(/\/.*$/, '') }.uniq.each do |cat|

      @category_list[cat] = 'sidebar-item-2' # by default
      if cat =~ /^(extragear-|calligra|koffice|others|www)/
        @category_list[cat] = 'sidebar-item-1'
      elsif cat =~ /^(playground-)/
        @category_list[cat] = 'sidebar-item-3'
      end
    end

    @selected_cat = params[:id] if @category_list.has_key?(params[:id])
    @category_list = @category_list.to_a.sort_by {|x| x.reverse }

    if @selected_cat
      @category_list.select {|x| x[0] == @selected_cat }[0][1] += ' sidebar-selected'

      # TODO: filter only files with moved_to=-1
      @files = TranslationFile.find(:all, :conditions => ['filename_with_path LIKE ?', @selected_cat + '/%'])
    end
  end

  verify :method => :post, :xhr => true, :only => :ajax_lock_pofile, #[:ajax_lock_pofile, :ajax_upload],
      :redirect_to => :home_url, :render => "hello"
  def ajax_lock_pofile
    x = TranslationFile.find(params[:id])
    x.toggle_locking(current_user)

    respond_to do |format|
      format.xml {
        render :partial => 'div_po_locking', :locals => { :file => TranslationFile.find(params[:id].to_i) }
        #render :xml => current_user.to_xml(:only => :login)
      }
    end
  end

  def ajax_upload
    p params
    x = TranslationFile.find(params[:id])

    respond_to do |format|
      format.xml {
        render :xml => "123"
      }
    end
  end

end
