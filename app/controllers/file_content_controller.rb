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

  def show
    @file = FileContent.find(params[:id])

    $po_backend.error_hook = lambda {|s| flash[:error] = s }
    if posieve = $po_backend.posieve
      @errors = posieve.check_rules(@file.content.to_file.read)
    else
      @errors = []
      flash[:error] = "Could not obtain result of checking."
    end
  end

end
