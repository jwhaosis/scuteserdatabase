class User < ActiveRecord::Base

  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  has_secure_password validations: false
  has_many :tweets
  has_many :following_someone, class_name: 'Follower', foreign_key: 'followed_by_id'
  has_many :followed_by_someone, class_name: 'Follower', foreign_key: 'user_id'
  has_many :following, through: :following_someone, source: :user
  has_many :followers, through: :followed_by_someone, source: :followed_by
  has_many :likes
  has_many :mentions
  has_many :hashtags

end
