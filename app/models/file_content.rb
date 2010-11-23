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

  protected
    def validate_on_create
      # This solution looks bad, because it doesn't use Paperclip validates_attachment_*
      # But another solution (http://mibly.com/2008/05/13/custom-validation-with-paperclip/) does not work
      res = $po_backend.gettext
      if res.nil?
        errors.add_to_base("po_backend not working")
      elsif res.check_po_validity(content.queued_for_write[:original].read)
        errors.add_to_base("Your file is not a Gettext translation file (.po)")
      end
    end
end
