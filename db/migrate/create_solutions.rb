"""
Author: Walter Teitelbaum
File: create_solutions.rb
Date: 4/1/2024
Modified: 4/1/2024

Description: This file will create the solutions table with the fields specified in the Solution model.
"""

require 'active_record'

class CreateSolutions < ActiveRecord::Migration[6.0]
  def change
    create_table :solutions do |t|
      t.integer :user_id
      t.integer :game_id
      t.datetime :timestamp
      t.string :chain

      t.timestamps
    end
  end
end
