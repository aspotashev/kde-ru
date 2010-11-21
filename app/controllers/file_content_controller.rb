class FileContentController < ApplicationController
  def create
    res = FileContent.create(params[:file_content].merge(:translation_file_id => params[:translation_file_id], :user_id => current_user.id))

    begin
      res.save!
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = e.record.errors.full_messages.join("\n")
    end

    redirect_to :back
  end

end
