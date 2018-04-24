require 'sinatra'
require 'sinatra/activerecord'
require 'em-http-request'
require 'redis'
require 'dotenv'
require './models/follower'
require './models/hashtag'
require './models/like'
require './models/mention'
require './models/tweet'
require './models/tweettag'
require './models/user'

Dotenv.load
$redis = Redis.new(:host => ENV["REDIS_URI"], :port => 10619, :password => ENV["REDIS_PASS"])

get '/' do
  "Welcome to the Scuteser database backend, why are you here?"
end

post '/create/like' do
  request.body.rewind
  model_params = JSON.parse request.body.read.to_s
  tweet_id = model_params["tweet_id"]
  tweet_info = eval $redis.get("tweet_info")
  if tweet_info[tweet_id].nil?
    tweet_info[tweet_id] = [1,0]
  else
    tweet_info[tweet_id][0] += 1
  end
  $redis.set("tweet_info", tweet_info)
  redis_key = "cache_like"
  model_array = $redis.get(redis_key)
  if model_array.nil?
    $redis.set(redis_key, [model_params])
  else
    $redis.set(redis_key, ((eval model_array).push model_params))
  end
end

post '/delete/like' do
  request.body.rewind
  model_params = JSON.parse request.body.read.to_s
  tweet_id = model_params["tweet_id"]
  tweet_info = eval $redis.get("tweet_info")
  if tweet_info[tweet_id].nil?
    tweet_info[tweet_id] = [0,0]
  else
    tweet_info[tweet_id][0] -= 1
  end
  $redis.set("tweet_info", tweet_info)
  redis_key = "cache_like"
  model_array = $redis.get(redis_key)
  if !model_array.nil?
    $redis.set(redis_key, ((eval model_array).delete model_params))
  end
end


post '/create/retweet' do
  request.body.rewind
  model_params = JSON.parse request.body.read.to_s
  tweet_id = model_params["retweet_id"]
  tweet_info = eval $redis.get("tweet_info")
  if tweet_info[tweet_id].nil?
    tweet_info[tweet_id] = [0,1]
  else
    tweet_info[tweet_id][1] += 1
  end
  $redis.set("tweet_info", tweet_info)
  redis_key = "cache_retweet"
  model_array = $redis.get(redis_key)
  if model_array.nil?
    $redis.set(redis_key, [model_params])
  else
    $redis.set(redis_key, ((eval model_array).push model_params))
  end
end

post '/delete/retweet' do
  request.body.rewind
  model_params = JSON.parse request.body.read.to_s
  tweet_id = model_params["retweet_id"]
  tweet_info = eval $redis.get("tweet_info")
  if tweet_info[tweet_id].nil?
    tweet_info[tweet_id] = [0,0]
  else
    tweet_info[tweet_id][1] -= 1
  end
  $redis.set("tweet_info", tweet_info)
  redis_key = "cache_retweet"
  model_array = $redis.get(redis_key)
  if !model_array.nil?
    $redis.set(redis_key, ((eval model_array).delete model_params))
  end
end

post '/create/:model' do
  redis_key = "#{ENV['DB_NUM']}_#{params[:model]}"
  request.body.rewind
  model_params = JSON.parse request.body.read.to_s
  model_array = $redis.get(redis_key)
  if model_array.nil?
    $redis.set(redis_key, [model_params])
  else
    $redis.set(redis_key, ((eval model_array).push model_params))
  end
end


get '/write' do
  user_array = []
  (eval ($redis.get "db1_users")).each do |user_params|
    user_array.push User.new(JSON.parse user_params)
  end
  user_array.each do |user|
    puts user.name
  end
  "placeholder"
end
