require 'csv'
require 'activerecord-import'
require_relative '../app/models/user'
require_relative '../app/models/follower'
require_relative '../app/models/tweet'
require_relative '../app/models/hashtag'
require_relative '../app/models/like'
require_relative '../app/models/tweettag'
require_relative '../app/models/mention'

#reset db
User.delete_all
Follower.delete_all
Tweet.delete_all
Hashtag.delete_all
Like.delete_all
Tweettag.delete_all
Mention.delete_all

users = []
followers = []
tweets = []
user_count = 0
follower_count = 0
tweet_count = 0

#load users
CSV.foreach('./db/seeds/users.csv') do |user|
  username = user[1].downcase.gsub(/\W+/, '')
  users << User.new(
      id: user_count+=1,
      name: username,
      email: "#{username}@email.com",
      password: "password"
  )
end

#load followers
CSV.foreach('./db/seeds/follows.csv') do |follow|
  user_id = follow[0]
  follows_user_id = follow[1]
  followers << Follower.new(
      id: follower_count+=1,
      user_id: follows_user_id.to_i,
      followed_by_id: user_id.to_i
  )
end

#load tweets
CSV.foreach('./db/seeds/tweets.csv') do |tweets_row|
  if (tweet_count < 2500)
  user_id = tweets_row[0]
  tweet = tweets_row[1]
  created_at = tweets_row[2]
  tweets << Tweet.new(
      id: tweet_count+=1,
      user_id: user_id.to_i,
      tweet: tweet,
      created_at: Date.parse(created_at)
  )
  end
end

sorted_tweets = tweets.sort_by &:created_at

ActiveRecord::Base.connection.execute("ALTER SEQUENCE users_id_seq restart with #{user_count+1}")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE followers_id_seq restart with #{follower_count+1}")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE tweets_id_seq restart with #{tweet_count+1}")

User.import users
Follower.import followers
Tweet.import sorted_tweets
