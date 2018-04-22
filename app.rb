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
uri = URI.parse(ENV["REDIS_URI"])
$redis = Redis.new(:host => uri, :port => 10619, :password => ENV["REDIS_PASS"])

get '/' do

end

post '/' do
  request.body.rewind
  data = request.body.read.to_s
  puts "-------------------#{request.media_type}---------------------------------"
  data
end

post '/user/create' do
  user_params = JSON.parse request.body
  user_array = $redis.get("db1_users")
  if user_array.nil?
    $redis.set("db1_users", [user_params])
  else
    $redis.set("db1_users", ((eval user_array).push user_params))
  end
end

# post '/tweet/create' do
#   tweet_params = JSON.parse request.body
#   tweet_array = $redis.get("db1_tweets")
#   if tweet_array.nil?
#     $redis.set("db1_tweets", [tweet_params])
#   else
#     $redis.set("db1_tweets", ((eval tweet_array).push tweet_params))
#   end
# end

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
