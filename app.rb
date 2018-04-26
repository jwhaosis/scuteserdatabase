require 'sinatra'
require 'sinatra/activerecord'
require 'em-http-request'
require 'eventmachine'
require 'redis'
require 'dotenv'
require 'faker'
require 'activerecord-import'
require './app/models/follower'
require './app/models/hashtag'
require './app/models/like'
require './app/models/mention'
require './app/models/tweet'
require './app/models/tweettag'
require './app/models/user'
require './like_retweet_routes'
Dotenv.load
$redis = Redis.new(:host => ENV["REDIS_URI"], :port => 17627, :password => ENV["REDIS_PASS"])

get '/' do
  "Welcome to the Scuteser database backend, why are you here?"
end

post '/create/tweet/:id' do
  request.body.rewind
  body = request.body.read.to_s
  if body == ""
    body = Faker::Hacker.say_something_smart
  end
  $redis.setnx "tweet_inc", Tweet.count+1
  id = $redis.get("tweet_inc")
  user_id = params[:id]
  $redis.incr "tweet_inc"
  new_tweet = Tweet.create(id: id, user_id: user_id, tweet: body, created_at: Time.now)
  new_tweet = (JSON.parse new_tweet.to_json)
  new_tweet["name"] = User.where(id: user_id).first&.name
  key = "user#{user_id}_tweets"
  info_key = "user#{user_id}_infos"
  user_tweets = $redis.get(key)
  if user_tweets.nil?
    user_tweets = Tweet.joins(:user).where(user_id: user_id).select("tweets.*, users.name").order(:created_at).last(50).reverse
  else
    user_tweets = JSON.parse user_tweets
    user_tweets.pop if(user_tweets.size > 49)
    user_tweets.unshift new_tweet
  end
  $redis.set(key, user_tweets.to_json)
  info = $redis.get info_key
  if !info.nil?
    info = JSON.parse info
    info["tweet_count"] += 1
    $redis.set(info_key, info.to_json)
  end
  global_tweets = $redis.get("global_tweet_record")
  if global_tweets.nil?
    $redis.set("global_tweet_record", [new_tweet].to_json)
  else
    $redis.set("global_tweet_record", ((JSON.parse global_tweets).push new_tweet).to_json)
  end
end

post '/create/:model' do
  redis_key = "global_#{params[:model]}_record"
  request.body.rewind
  model_params = JSON.parse request.body.read.to_s
  model_array = $redis.get(redis_key)
  if model_array.nil?
    $redis.set(redis_key, [model_params])
  else
    $redis.set(redis_key, ((eval model_array).push model_params))
  end
end

post '/sync' do
  unsynced_users = $redis.get "global_user_record"
  unsynced_tweets = $redis.get "global_tweet_record"
  unsynced_likes = $redis.get "global_like_record"
  unsynced_follows = $redis.get "global_follower_record"
  unsynced_users = JSON.parse unsynced_users if !unsynced_users.nil?
  unsynced_tweets = JSON.parse unsynced_tweets if !unsynced_tweets.nil?
  unsynced_likes = JSON.parse unsynced_likes if !unsynced_likes.nil?
  unsynced_follows = JSON.parse unsynced_follows if !unsynced_follows.nil?

  unsynced_users&.each do |user_params|
    begin
      User.create(user_params)
    rescue
      puts "exists"
    end
  end

  unsynced_tweets&.each do |tweets_params|
    begin
      Tweet.create(tweets_params)
    rescue
      puts "exists"
    end
  end

  unsynced_likes&.each do |like_params|
    begin
      Like.create(like_params)
    rescue
      puts "exists"
    end
  end

  unsynced_follows&.each do |follow_params|
    begin
      Follower.create(follow_params)
    rescue
      puts "exists"
    end
  end
end
