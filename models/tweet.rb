class Tweet < ActiveRecord::Base
  belongs_to :user
  has_many :retweets, class_name: 'Tweet', foreign_key: 'retweet_id'
  has_many :mentions
  has_many :tweettags
  has_many :likes
end
