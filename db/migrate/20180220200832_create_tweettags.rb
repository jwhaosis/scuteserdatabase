class CreateTweettags < ActiveRecord::Migration[5.1]
  def change
    create_table :tweettags do |t|
      t.integer :hashtag_id
      t.integer :tweet_id
    end
  end
end
