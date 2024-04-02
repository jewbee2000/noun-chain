"""
Author: Walter Teitelbaum
File: wordchain.rb
Date: 4/1/2024
Modified: 4/1/2024

Description: This file contains the backend for the wordchain game.
"""

require 'sinatra/base'
require './models/game'
require './models/user'
require './models/solution'
require 'json'

class App < Sinatra::Base
  # GET /game
  get '/game' do
    @game = Game.find_by(date: Date.today)
    if @game
      @game.to_json
    else
      # TODO: handle error
    end
  end

  # GET /stats
  get '/stats' do
    @users = User.all
    @users.to_json
  end
end
