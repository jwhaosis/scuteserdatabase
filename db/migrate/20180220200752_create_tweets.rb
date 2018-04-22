class CreateTweets < ActiveRecord::Migration[5.1]
  def change
    create_table :tweets do |t|
      t.string :tweet
      t.timestamp :created_at
      t.integer :user_id
      t.integer :retweet_id
    end
  end
end
