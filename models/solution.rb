"""
Author: Walter Teitelbaum
File: solution.rb
Date: 4/1/2024
Modified: 4/1/2024

Description: This file contains the solution model for the wordchain game.
"""

require 'sinatra/activerecord'

class Solution < ActiveRecord::Base
  belongs_to :game
  belongs_to :user

  attribute :user_id, :integer
  attribute :game_id, :integer
  attribute :timestamp, :datetime
  attribute :chain, :string
end
