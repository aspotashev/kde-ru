class FileContent < ActiveRecord::Base
  belongs_to :user
  belongs_to :translation_file

  has_attached_file :content
end
