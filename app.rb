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
  helpers do
    def success_response(data)
      {
        status: 'success',
        data: data
      }.to_json
    end

    def fail_response(data)
      {
        status: 'fail',
        data: data
      }.to_json
    end

    def error_response(message, code = nil, data = nil)
      response = {
        status: 'error',
        message: message
      }
      response[:code] = code if code
      response[:data] = data if data
      response.to_json
    end

    def valid_soln(game, noun_array)
      # TODO: also check with the dictionary that the noun_array is a valid chain of compounds
      return (game.start_word == noun_array.first &&
              game.end_word == noun_array.last)
    end
  end

  before do
    uuid = request.cookies['uuid']
    @user = User.find_by(uuid: uuid)
    unless @user
      @user = User.create
      response.set_cookie("uuid", :value => @user.uuid)
      halt 401, { 'Content-Type' => 'application/json' },
      error_response(message: 'Error, UUID not found', code: 401)
    end
  end

  # GET /game
  get '/game' do
    @game = Game.find_by(date: Date.today)
    if @game
      success_response(@game)
    else
      error_response("No game found for today's date.", 404)
    end
  end

  # GET /stats
  get '/stats' do
    success_response(@user)
  end

  # PUT /soln
  put '/soln' do
    @game = Game.find_by(date: Date.today) # today's game
    p params
    if @game && @game.date == Date.today
      @solution = Solution.find_by(user_id: @user.id, game_id: @game.id)

      if @solution
        if @solution.update(params[:solution])
          success_response(@solution)
        else
          error_response("Failed to update the solution.", 400)
        end
      else
        error_response("No solution found for the provided user and game.", 404)
      end
    else
      error_response("No game found with the provided game number, or the game is not for today's date.", 404)
    end
  end

end
