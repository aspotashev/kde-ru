class TranslationFile < ActiveRecord::Base
  def is_locked?
    user_locked != -1
  end
  
  # Returns true if the file is locked, and it wasn't the current user to lock it
  def is_locked_by_other?(current_user)
    is_locked? and user_locked != current_user.id
  end
  
  # TODO: if you are admin, you should be able to do everything
  def can_lock?(current_user)
    not is_locked?
  end
  
  # TODO: if you are admin, you should be able to do everything
  def can_unlock?(current_user)
    is_locked? and not is_locked_by_other?(current_user)
  end
end
