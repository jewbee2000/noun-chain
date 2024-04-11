"""
Authors: Walter Teitelbaum, Ben Teitelbaum
File: wordchain.rb
Date: 4/1/2024
Modified: 4/3/2024

Description: This file contains the backend for the wordchain game.
"""

require 'sinatra/base'
require 'sinatra/reloader' if development?
require './models/game'
require './models/user'
require './models/solution'
require "redis"
require 'json'

class App < Sinatra::Base

  set :default_content_type, :json
  set :public_folder, 'public'

  helpers do
    def success_response(data, http_status = 200)
      status http_status
      {
        status: 'success',
        data: data
      }.to_json
    end

    def fail_response(data, http_status = 404)
      status http_status
      {
        status: 'fail',
        data: data
      }.to_json
    end

    def valid_soln(game, noun_array)
      # Initialize Redis
      redis = Redis.new(host: "127.0.0.1", port: 6379)

      # # Check Redis connection
      # begin
      #   pong = redis.ping
      #   puts "Redis connection successful: #{pong}"
      # rescue Redis::CannotConnectError
      #   puts "Cannot connect to Redis"
      #   return false
      # end

      # Check each compound noun in the array
      noun_array.each_cons(2) do |first_noun, second_noun|
        compound_noun = "#{first_noun} #{second_noun}".downcase
        # puts "Checking compound noun: #{compound_noun}"
        # If the compound noun does not exist in Redis, return false
        compound_noun_value = redis.get(compound_noun)
        # puts "Value of #{compound_noun} in Redis: #{compound_noun_value}"
        if compound_noun_value.nil?
          # puts "Compound noun #{compound_noun} does not exist in Redis"
          return false
        else
          # puts "Compound noun #{compound_noun} exists in Redis"
        end
      end

      # If all compound nouns exist in Redis, return true
      # puts "All compound nouns exist in Redis"
      true
    end
  end

  before do

    uuid = request.cookies['uuid']
    @user = User.find_by(uuid: uuid)
    unless @user
      @user = User.create
      response.set_cookie("uuid", :value => @user.uuid)
      fail_response("uuid not found")
    end
  end

  # GET /
  get '/' do
    send_file 'index.html'
  end

  # GET /game
  get '/game' do
    @game = Game.find_by(date: Date.today)
    if @game
      success_response(@game)
    else
      fail_response("No game found for today's date.")
    end
  end

  # GET /stats
  get '/stats' do
    success_response(@user)
  end

  # POST /soln
  post '/soln' do
    data = JSON.parse(request.body.read)
    puts "Received data: #{data}"
    @game = Game.find_by(date: Date.today) # today's game
    if data['d'].is_a?(Array) && valid_soln(@game, data['d'])
      # TODO increment the user's stats
      success_response(@user)
    else
      # puts "Data: #{data}"
      fail_response({soln: 'invalid solution'})
    end
  end

end
