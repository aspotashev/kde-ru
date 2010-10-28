class AdminController < ApplicationController
  before_filter :login_required

  def test_jquery
  end

  def polist
    @files = TranslationFile.find(:all) # TODO: filter only files with moved_to=-1
  end
  
  
#  verify :method => :post, :xhr => true, :only => :ajax_lock_pofile,
#      :redirect_to => :home_url, :render => "hello"
  def ajax_lock_pofile
    p TranslationFile.find(params[:id]).user_locked
    p '-------'
    x = TranslationFile.find(params[:id])
    p x
    x.unlock
    x.user_locked = -1
    p x
    p '-------'
    p TranslationFile.find(params[:id]).user_locked
    respond_to do |format|
      format.xml {
	render :partial => 'div_po_locking', :locals => { :file => TranslationFile.find(params[:id].to_i) }
	#render :xml => current_user.to_xml(:only => :login)
      }
    end
  end
end
