# One object of TranslationFile per file name
# (there is only one instance of TranslationFile for
# kdebase/dolphin.po, for example)
class TranslationFile < ActiveRecord::Base
  has_many :file_contents

# checks
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

# actions
  def unlock
    self.user_locked = -1
    save!
  end

  def lock(user_id)
    self.user_locked = user_id
    save!
  end

  # lock if unlocked, unlock if locked
  def toggle_locking(current_user)
    if is_locked?
      unlock if can_unlock?(current_user)  # TODO: raise exception or report error here?
    else
      lock(current_user.id) if can_lock?(current_user)  # TODO: raise exception or report error here?
    end
  end
end
