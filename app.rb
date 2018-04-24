require 'sinatra'
require 'sinatra/activerecord'
require 'em-http-request'
require 'redis'
require 'dotenv'
require 'faker'

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
  $redis.incr "tweet_inc"
  Tweet.new(id: id, user_id: params[:id], tweet: body, created_at: Faker::Date.backward(14))
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
