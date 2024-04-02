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
      status 404
      "Error: No game found for today's date."
    end
  end

  # GET /stats
  get '/stats' do
    uuid = request.cookies['user_uuid']
    @user = User.find_by(uuid: uuid)
    if @user
      @user.to_json
    else
      status 404
      "Error: No user found with the provided UUID."
    end
  end

  # PUT /soln
  put '/soln' do
    uuid = request.cookies['user_uuid']
    @user = User.find_by(uuid: uuid)
    @game = Game.find_by(game_number: params[:game_id])

    if @game && @game.date == Date.today
      @solution = Solution.find_by(user_id: @user.id, game_id: @game.id)

      if @solution
        if @solution.update(params[:solution])
          @solution.to_json
        else
          status 400
          "Error: Failed to update the solution."
        end
      else
        status 404
        "Error: No solution found for the provided user and game."
      end
    else
      status 404
      "Error: No game found with the provided game number, or the game is not for today's date."
    end
  end

end
