class TranslationBranch < ActiveRecord::Base
  validates_presence_of :name

  has_many :file_branchings
  has_many :translation_files, :through => :file_branchings
  
  def self.create_by_name(s)
    find_by_name(s) or create(:name => s)
  end
end
