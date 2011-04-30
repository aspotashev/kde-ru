class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Stalker.enqueue("deliver_signup_notification", :user_id => user.id)
  end

  def after_save(user)
    if user.recently_activated? and user.activated_at
      Stalker.enqueue("deliver_activation", :user_id => user.id)
    end
  end
end
