class User < ActiveRecord::Base

  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  has_secure_password validations: false
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  has_many :tweets
  has_many :following_someone, class_name: 'Follower', foreign_key: 'followed_by_id'
  has_many :followed_by_someone, class_name: 'Follower', foreign_key: 'user_id'
  has_many :following, through: :following_someone, source: :user
  has_many :followers, through: :followed_by_someone, source: :followed_by
  has_many :likes
  has_many :mentions
  has_many :hashtags

  def User.digest string
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated? remember_token
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def following_tweets user_id
    Tweet.where("user_id IN (SELECT user_id FROM followers WHERE followed_by_id = #{user_id})")
  end
end
