require 'sinatra'
require 'sinatra/activerecord'
require 'em-http-request'
require 'redis'
require 'dotenv'
require 'faker'
require 'activerecord-import'
require './models/follower'
require './models/hashtag'
require './models/like'
require './models/mention'
require './models/tweet'
require './models/tweettag'
require './models/user'
require './like_retweet_routes'
Dotenv.load
$redis = Redis.new(:host => ENV["REDIS_URI"], :port => 10619, :password => ENV["REDIS_PASS"])

get '/' do
  "Welcome to the Scuteser database backend, why are you here?"
end

post '/create/tweet/:id' do
  request.body.rewind
  body = request.body.read.to_s
  if body.nil?
    body = Faker::Hacker.say_something_smart
  end
  id = $redis.get("tweet_inc")
  $redis.setnx "tweet_inc", Tweet.count
  $redis.incr "tweet_inc"
  key = "user#{id}_tweets"
  user_tweets = $redis.get(key)
  new_tweet = Tweet.create(id: id, user_id: params[:id], tweet: body, created_at: Time.now)
  if user_tweets.nil?
    user_tweets = Tweet.joins(:user).where(user_id: id).select("tweets.*, users.name").order(:created_at).last(50).reverse.to_json
  else
    user_tweets = JSON.parse user_tweets
    user_tweets.pop
    user_tweets.unshift new_tweet
  end
  $redis.set(key, user_tweets.to_json)
  global_tweets = JSON.parse $redis.get("global_tweet_record")
  if global_tweets.nil?
    $redis.set("global_tweet_record", [new_tweet].to_json)
  else
    $redis.set("global_tweet_record", (global_tweets.push new_tweet).to_json)
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

get '/sync' do
  unsynced_users = JSON.parse $redis.get "global_user_record"
  unsynced_tweets = JSON.parse $redis.get "global_tweet_record"
  unsynced_likes = JSON.parse $redis.get "global_like_record"
  unsynced_follows = JSON.parse $redis.get "global_follower_record"

  users = []
  unsynced_users.each do |user_params|
    users << User.new(user_params)
  end
  User.import users

  tweets = []
  unsynced_tweets.each do |tweets_params|
    tweets << Tweet.new(tweets_params)
  end
  Tweet.import tweets

  likes = []
  unsynced_likes.each do |like_params|
    likes << Like.new(like_params)
  end
  Like.import likes

  follows = []
  unsynced_follows.each do |follow_params|
    follows << Follower.new(follow_params)
  end
  Follower.import follows
end
