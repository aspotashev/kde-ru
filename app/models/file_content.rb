class FileContent < ActiveRecord::Base
  belongs_to :user
  belongs_to :translation_file

  validates_presence_of :user, :translation_file

  has_attached_file :content
  validates_attachment_presence :content

  # This doesn't help (rails still crashes on uploads > 2mb).
  # To be safe, add "LimitRequestBody 2097152" to apache2 config.
  validates_attachment_size :content, :less_than => 2.megabytes

#  validates_attachment_valid_po :content # valid .po translation file

  # TODO: if you are admin, you should be able to do everything
  def can_delete?(current_user)
    raise "current_user == nil" if current_user.nil?
    raise "user == nil" if user.nil?

    user.id == current_user.id && !current_user.anonymous?
  end

  # TODO: allow only "delete" HTTP method
  def delete(current_user)
    if can_delete?(current_user)
      force_delete
    else
      errors.add_to_base("you are not allowed to remove this FileContent")
      raise "you are not allowed to remove this FileContent"
    end
  end

  def pology_check_done?
    (not pology_errors_cache.nil?) and (not pology_errors_cache.empty?)
  end

  def read_content
    content.to_file.read
  end

  def force_delete
    destroy_attached_files # delete attachments (files from disk)
    destroy # remove record from database
  end
end
