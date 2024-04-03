"""
Author: Walter Teitelbaum
File: create_games.rb
Date: 4/1/2024
Modified: 4/1/2024

Description: This file will create the games table with the fields specified in the Game model.
"""

require 'active_record'

class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.integer :game_number
      t.datetime :date
      t.string :start_word
      t.string :end_word
      t.string :shortest_path

      t.timestamps
    end
  end
end
