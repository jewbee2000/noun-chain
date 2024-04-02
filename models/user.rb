"""
Author: Walter Teitelbaum
File: user.rb
Date: 4/1/2024
Modified: 4/1/2024

Description: This file contains the user model for the wordchain game.
"""

require 'sinatra/activerecord'
require 'securerandom'

class User < ActiveRecord::Base
  has_many :solutions

  attribute :uuid, :string, default: -> { assign_uuid(5) }
  attribute :won, :integer, default: 0
  attribute :current_streak, :integer, default: 0
  attribute :max_streak, :integer, default: 0
  attribute :plus_1, :integer, default: 0
  attribute :plus_2, :integer, default: 0
  attribute :plus_3, :integer, default: 0
  attribute :plus_4, :integer, default: 0
  attribute :plus_5, :integer, default: 0
  attribute :plus_more, :integer, default: 0

  def self.assign_uuid(length)
    # try twice, then increase length and recurse
    2.times do
      candidate = SecureRandom.alphanumeric(length)
      return candidate unless User.find_by_uuid(candidate)
    end
    assign_uuid(length + 1)
  end
end
