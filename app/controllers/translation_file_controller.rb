class TranslationFileController < ApplicationController
  def index
    @file = TranslationFile.find(params[:id])
  end

end
