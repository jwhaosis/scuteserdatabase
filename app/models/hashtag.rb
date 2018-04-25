class Hashtag < ActiveRecord::Base
  belongs_to :user
  belongs_to :tweet
  has_many :tweettags
end
