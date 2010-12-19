class UserCreateAnonymous < ActiveRecord::Migration
  def self.up
    User.delete_observers
    o = User.new({:login => 'anonymous'})
    o.id = -1
    o.save_without_validation!
  end

  def self.down
    User.delete(-1)
  end
end
