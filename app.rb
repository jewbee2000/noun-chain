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
  before do
    uuid = request.cookies['uuid']
    @user = User.find_by(uuid: uuid)
    unless @user
      @user = User.create
      response.set_cookie("uuid", :value => @user.uuid)
      halt 401, { 'Content-Type' => 'application/json' }, 
      { error: 'Error, UUID not found' }.to_json
    end
  end

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
    @user.to_json
  end

  # PUT /soln
  put '/soln' do
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
