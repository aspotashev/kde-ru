class FileBranching < ActiveRecord::Base
  validates_presence_of :translation_branch_id
  validates_presence_of :translation_file_id

  belongs_to :translation_branch
  belongs_to :translation_file

  # TODO: something for file_content (belongs_to or has_one?)
end
