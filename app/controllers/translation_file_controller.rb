class TranslationFileController < ApplicationController
#  before_filter :login_required

  def index
    @file = TranslationFile.find(params[:id])
  end

end
