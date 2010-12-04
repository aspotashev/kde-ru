class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://l10n.kde.ru/users/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://l10n.kde.ru/"
  end
  
  protected
    def setup_email(user)
      @recipients  = user.email
      @from        = "aspotashev@gmail.com"
      @subject     = "" #"[l10n.kde.ru] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
