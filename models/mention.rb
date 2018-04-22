class Mention < ActiveRecord::Base
  belongs_to :tweet
  has_many :users
end