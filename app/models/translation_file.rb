# One object of TranslationFile per file name
# (there is only one instance of TranslationFile for
# kdebase/dolphin.po, for example)
class TranslationFile < ActiveRecord::Base
  has_many :file_contents

  has_many :file_branchings
  has_many :translation_branches, :through => :file_branchings

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
    return false if current_user.anonymous?

    not is_locked?
  end

  # TODO: if you are admin, you should be able to do everything
  def can_unlock?(current_user)
    return false if current_user.anonymous?

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

  def can_toggle_locking?(current_user)
    if is_locked?
      can_unlock?(current_user)
    else
      can_lock?(current_user)
    end
  end

  # lock if unlocked, unlock if locked
  def toggle_locking(current_user)
    if can_toggle_locking?(current_user)
      p 'CAN TOGGLE'
      is_locked? ? unlock : lock(current_user.id) # TODO: raise exception or report error here?
    end
  end

  def basename # TODO: replace filename_with_path with basename
    File.basename(filename_with_path)
  end

  # create or return existing
  def self.create_by_name(s)
    find_by_filename_with_path(s) or create(:filename_with_path => s)
  end

  def self.all_except_dump
    find(:all, :conditions => [ "filename_with_path <> ?", '<DUMP>' ])
  end

end
