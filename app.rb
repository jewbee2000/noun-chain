"""
Authors: Walter Teitelbaum, Ben Teitelbaum
File: app.rb
Date: 4/1/2024
Modified: 4/3/2024

Description: This file contains the backend for the wordchain game.
"""

require 'sinatra/base'
require './models/game'
require './models/user'
require './models/solution'
require "redis"
require 'rack/cors'
require 'json'

class App < Sinatra::Base
  # TODO: This could be a security risk, but it's fine for now
  use Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: [:get, :post, :options]
    end
  end

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

    # Returns the compound noun of two normalized nouns
    def normalized_compound(n1, n2)
      "#{n1} #{n2}".downcase
    end

    def valid_soln(game, noun_array)
      # Initialize Redis
      redis = Redis.new(host: "127.0.0.1", port: 6379)

      # Check each compound noun in the array
      noun_array.each_cons(2) do |first_noun, second_noun|
        compound_noun = normalized_compound(first_noun, second_noun)
        # If the compound noun does not exist in Redis, return false
        unless redis.exists?(compound_noun)
          return false
        end
      end
      # If all compound nouns exist in Redis, return true
      true
    end
  end

  before do
    uuid = request.cookies['uuid']
    puts "UUID from cookie: #{uuid}"
    @user = User.find_by(uuid: uuid)
    unless @user
      @user = User.create
      response.set_cookie('uuid', value: @user.uuid, path: '/')
      puts "New UUID set in cookie: #{@user.uuid}"
    end
  end

  # GET /
  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
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

  #POST /chain
  post '/chain' do
    data = JSON.parse(request.body.read)
    puts "Received data: #{data}"

    is_valid = data['d'].is_a?(Array) && valid_soln(@game, data['d'])
    puts "Is valid: #{is_valid}"

    if is_valid
      success_response({chain: 'valid'})
    else
      fail_response({chain: 'invalid'})
    end
  end


  # POST /soln
  post '/soln' do
    data = JSON.parse(request.body.read)
    @game = Game.find_by(date: Date.today)

    # Add a check for @game
    unless @game
      return fail_response("No game found for today's date.", 404)
    end

    # check if the solution is valid and that the first and last words are the start and end words
    if data['d'].is_a?(Array) && valid_soln(@game, data['d']) && data['d'].first == @game.start_word && data['d'].last == @game.end_word
      # increment the user's stats based on how long their solution is compared to the shortest path of today's game
      shortest_path_length = @game['shortest_path']
      user_solution_length = data['d'].length
      difference = user_solution_length - shortest_path_length

      if difference == 0
        @user.won += 1
        @user.current_streak += 1
        @user.max_streak = [@user.max_streak, @user.current_streak].max
      elsif difference.between?(1, 5)
        @user["plus_#{difference}"] += 1
        @user.current_streak = 0
      else
        @user.plus_more += 1
      end

      @user.save
      success_response(@user)
    else
      @user.current_streak = 0
      @user.save
      fail_response({soln: 'invalid solution'})
    end
  end

end
