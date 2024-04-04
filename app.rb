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
    end
  end

  # GET /game
  get '/game' do
    @game = Game.find_by(date: Date.today)
    if @game
      success_response(@game)
    else
      fail_response("No game found for today's date.")    end
  end

  # GET /stats
  get '/stats' do
    success_response(@user)
  end

  # PUT /soln
  put '/soln' do
    @game = Game.find_by(date: Date.today) # today's game
    if valid_soln(@game, params['d'])
      # TODO increment the user's stats
      success_response(@user)
    else
      fail_response({soln: 'invalid solution'})
    end
  end

end
