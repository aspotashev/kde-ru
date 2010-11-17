class FileContent < ActiveRecord::Base
  belongs_to :user
  belongs_to :translation_file

  validates_presence_of :user, :translation_file

  has_attached_file :content
end
