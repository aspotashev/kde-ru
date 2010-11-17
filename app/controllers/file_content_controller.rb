class FileContentController < ApplicationController
  def create
    if not FileContent.create(params[:file_content].merge(:translation_file_id => params[:translation_file_id], :user_id => current_user.id))
      flash[:error] = "Could not create FileContent"
    end

    redirect_to :back
  end

end
