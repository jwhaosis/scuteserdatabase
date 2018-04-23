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

post '/async' do
  sleep(10)
end

post '/' do
  request.body.rewind
  data = request.body.read.to_s
  # puts "-------------------#{request.media_type}---------------------------------"
  # puts "-------------------#{request.env['rack.input'].read}---------------------"
  # puts "--------------------#{data.class}------------------"
  # puts "--------------------#{data}----------------------"
  $redis.set("test", data)
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
