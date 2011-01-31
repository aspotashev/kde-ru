class UserCreateRepository < ActiveRecord::Migration
  def self.up
    User.delete_observers
    o = User.new({:login => 'repository'})
    o.id = -2
    o.save_without_validation!
  end

  def self.down
    User.delete(-2)
  end
end
