class Tweettag < ActiveRecord::Base
  belongs_to :tweets
  belongs_to :hashtags
end
