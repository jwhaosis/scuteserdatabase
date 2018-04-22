class CreateTweets < ActiveRecord::Migration[5.1]
  def change
    create_table :tweets do |t|
      t.string :tweet
      t.timestamp :created_at
      t.integer :user_id
      t.integer :retweet_id

      t.index ["retweet_id"], name: "index_tweets_on_retweet_id"
    end
  end
end
