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

  redis_key = "global_like_record"
  model_array = $redis.get(redis_key)
  if model_array.nil?
    $redis.set(redis_key, [model_params].to_json)
  else
    $redis.set(redis_key, ((JSON.parse model_array).delete model_params).to_json)
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

  redis_key = "global_like_record"
  model_array = $redis.get(redis_key)
  if !model_array.nil?
    $redis.set(redis_key, ((JSON.parse model_array).delete model_params).to_json)
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

  redis_key = "global_tweet_record"
  model_array = $redis.get(redis_key)
  if model_array.nil?
    $redis.set(redis_key, [model_params].to_json)
  else
    $redis.set(redis_key, ((JSON.parse model_array).push model_params).to_json)
  end
end
