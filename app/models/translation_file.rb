class TranslationFile < ActiveRecord::Base
  def is_locked?
    user_locked != -1
  end
end
