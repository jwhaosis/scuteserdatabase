class CreateMentions < ActiveRecord::Migration[5.1]
  def change
    create_table :mentions do |t|
      t.integer :tweet_id
      t.integer :mentioned_user_id
    end
  end
end
