module Paperclip
  module ClassMethods
    def validates_attachment_valid_po(name)
      # http://mibly.com/2008/05/13/custom-validation-with-paperclip/
      # 
      # this does not work!!! (@attachment_definitions is nil)
      @attachment_definitions[name][:validations] << lambda do |attachment, instance|
        if attachment.file.nil? || !File.exist?(attachment.file.path)
          "must be set"
        else
          return $po_backend.gettext.check_po_validity(File.open(attachment.file.path).read)
	end
      end
    end
  end
end
