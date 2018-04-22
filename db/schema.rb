# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180220200832) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "followers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "followed_by_id"
  end

  create_table "hashtags", force: :cascade do |t|
    t.string "hashtag"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "tweet_id"
    t.index ["tweet_id"], name: "index_likes_on_tweet_id"
  end

  create_table "mentions", force: :cascade do |t|
    t.integer "tweet_id"
    t.integer "mentioned_user_id"
  end

  create_table "tweets", force: :cascade do |t|
    t.string "tweet"
    t.datetime "created_at"
    t.integer "user_id"
    t.integer "retweet_id"
    t.index ["retweet_id"], name: "index_tweets_on_retweet_id"
  end

  create_table "tweettags", force: :cascade do |t|
    t.integer "hashtag_id"
    t.integer "tweet_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "remember_digest"
  end

end
