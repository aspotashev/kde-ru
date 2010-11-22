class FileContentController < ApplicationController
  include FileContentHelper

  before_filter :login_required

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
    @errors = posieve_check_rules(@file)

    if @errors.nil?
      @errors = []
      flash[:error] = "Could not obtain result of checking."
    end
  end

end
