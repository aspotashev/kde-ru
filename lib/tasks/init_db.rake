
namespace :db do
  desc "Erase and fill database"

  task :init_db => :environment do
    FileContent.delete_all
    #OpenIdAuthenticationAssociation.delete_all
    #OpenIdAuthenticationNonce.delete_all
    TranslationFile.delete_all
    User.delete_all


    TranslationFile.create(:filename_with_path => '<DUMP>')
  end
end

