"""
Author: Walter Teitelbaum
File: wordchain.rb
Date: 4/1/2024
Modified: 4/1/2024

Description: This file contains the backend for the wordchain game.
"""

require 'sinatra'
require 'sqlite3'
require 'json'

# Enable sessions
enable :sessions

# Connect to the SQLite database
db = SQLite3::Database.new('wordchain.db')

# Define the user model
class User < ActiveRecord::Base
  has_many :Game
end

# Define the game model
class Game < ActiveRecord::Base
end

# Define the solution model
class Solution < ActiveRecord::Base
  belongs_to :User
  belongs_to :Game
end

# Create the users table if it doesn't exist
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS users (
    UUID INTEGER PRIMARY KEY AUTOINCREMENT,
    Played INTEGER DEFAULT 0,
    Won INTEGER DEFAULT 0,
    Current_streak INTEGER DEFAULT 0,
    Max_streak INTEGER DEFAULT 0,
    Plus_1 INTEGER DEFAULT 0,
    Plus_2 INTEGER DEFAULT 0,
    Plus_3 INTEGER DEFAULT 0,
    Plus_4 INTEGER DEFAULT 0,
    Plus_5 INTEGER DEFAULT 0,
    Plus_More INTEGER DEFAULT 0
  );
SQL

# Create the games table if it doesn't exist
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS games (
      Number INTEGER,
      Date TEXT PRIMARY KEY,
      Start_Word TEXT,
      End_Word TEXT,
      Shortest_Solution INTEGER
    );
SQL

# Create the solutions table if it doesn't exist
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS solutions (
        User_id INTEGER PRIMARY KEY AUTOINCREMENT,
        Game_id INTEGER,
        Timestamp TEXT,
        Chain TEXT
      );
SQL

# Endpoint to get user stats
get '/stats' do
  # Retrieve user stats from the database
  stats = db.execute("SELECT played, won, current_streak, max_streak, plus_1, plus_2, plus_3, plus_4, plus_5, plus_more FROM users WHERE UUID = ?", session[:uuid])

  # Format the stats as JSON
  stats.to_json
end

# Endpoint to get today's game
get '/game' do
  # Get today's date in the format "ddmmyyyy"
  today = Time.now.strftime("%d%m%Y")

  # Retrieve today's game from the database
  game = db.execute("SELECT Number, Start_Word, End_Word, Shortest_Solution FROM games WHERE Date = ?", today)

  # If there's no game for today, return an error message
  if game.empty?
    return "No game for today."
  end

  # Format the game as JSON
  game.to_json
end

# Homepage
get '/' do
  # Create a new user and store their UUID in the session
  db.execute("INSERT INTO users (Played) VALUES (0)")
  session[:uuid] = db.last_insert_row_id

  "Welcome!"
end

# Run the app
run!
