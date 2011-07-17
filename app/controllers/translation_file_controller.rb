class TranslationFileController < ApplicationController
#  before_filter :login_required

  def index
    @file = TranslationFile.find(params[:id])
  end

  def polist
    @category_list = {
      'extragear-games' => 'sidebar-item-1',
      'extragear-multimedia' => 'sidebar-item-1',
      'kdebase' => 'sidebar-item-2',
      'kdelibs' => 'sidebar-item-2',
      'playground-pim' => 'sidebar-item-3',
    }

    @selected_cat = params[:id] if @category_list.has_key?(params[:id])
    if @selected_cat
      @category_list[@selected_cat] += ' sidebar-selected'

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
