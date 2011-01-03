class FileContentController < ApplicationController
  include FileContentHelper

  before_filter :login_required, :except => [:show, :create]

  def create
    $po_backend.error_hook = lambda {|s| flash[:error] = s } # TODO: where should this be?
    res = FileContent.create(params[:file_content].merge(
      :translation_file_id => params[:translation_file_id],
      :user_id => current_user.id))

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
  end

  def delete
    @file = FileContent.find(params[:id])
    @file.delete(current_user)
    redirect_to :back
  end

end
