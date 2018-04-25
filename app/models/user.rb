class User < ActiveRecord::Base
  has_many :tweets
  has_many :following_someone, class_name: 'Follower', foreign_key: 'followed_by_id'
  has_many :followed_by_someone, class_name: 'Follower', foreign_key: 'user_id'
  has_many :following, through: :following_someone, source: :user
  has_many :followers, through: :followed_by_someone, source: :followed_by
  has_many :likes
  has_many :mentions
  has_many :hashtags

end
