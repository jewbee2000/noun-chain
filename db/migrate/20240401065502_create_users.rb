"""
Author: Walter Teitelbaum
File: create_users.rb
Date: 4/1/2024
Modified: 4/1/2024

Description: This file will create the users table with the fields specified in the User model.
"""

require 'active_record'

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :uuid
      t.integer :won
      t.integer :current_streak
      t.integer :max_streak
      t.integer :plus_1
      t.integer :plus_2
      t.integer :plus_3
      t.integer :plus_4
      t.integer :plus_5
      t.integer :plus_more

      t.timestamps
    end
  end
end
