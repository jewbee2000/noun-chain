"""
Author: Walter Teitelbaum
File: game.rb
Date: 4/1/2024
Modified: 4/1/2024

Description: This file contains the game model for the wordchain game.
"""

require 'sinatra/activerecord'

class Game < ActiveRecord::Base
  has_many :solutions

  attribute :game_number, :integer
  attribute :date, :datetime
  attribute :start_word, :string
  attribute :end_word, :string
  attribute :shortest_path, :integer
end
