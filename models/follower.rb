require 'active_record'

class Follower < ActiveRecord::Base
  belongs_to :user, class_name: 'User'
  belongs_to :followed_by, class_name: 'User'
end
