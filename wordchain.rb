"""
Author: Walter Teitelbaum
File: wordchain.rb
Date: 4/1/2024
Modified: 4/1/2024

Description: This file contains the backend for the wordchain game.
"""

require 'sinatra'
require 'sqlite3'

# Connect to the SQLite database
db = SQLite3::Database.new('wordchain.db')

# Create the users table if it doesn't exist
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    played INTEGER DEFAULT 0,
    won INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    max_streak INTEGER DEFAULT 0,
    dist ARRAY DEFAULT [0, 0, 0, 0, 0, 0, 0]
  );
SQL

# Endpoint to get user stats
get '/stats' do
  # Retrieve user stats from the database
  stats = db.execute("SELECT played, won, current_streak, max_streak, dist FROM users")

  # Format the stats as JSON
  stats.to_json
end

# Homepage
get '/' do
  "Welcome!"
end

# Run the app
run!
