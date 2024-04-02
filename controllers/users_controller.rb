"""
Author: Walter Teitelbaum
File: users_controller.rb
Date: 4/1/2024
Modified: 4/1/2024

Description: This file will handle CRUD operations for users.
"""

require 'sinatra/base'
require './models/user'

class UsersController < Sinatra::Base
  # Create
  post '/users' do
    @user = User.new(params[:user])
    if @user.save
      response.set_cookie('user_uuid', value: @user.uuid, secure: true, httponly: true)
      redirect to("/users/#{@user.id}")
    else
      status 400
      "Error: Failed to create user."
    end
  end

  # Read
  get '/users/:id' do
    uuid = request.cookies['user_uuid']
    @user = User.find_by(uuid: uuid)
    if @user
      # TODO: render game stats view
    else
      status 404
      "Error: No user found with the provided UUID."
    end
  end

  # Update
  put '/users/:id' do
    uuid = request.cookies['user_uuid']
    @user = User.find_by(uuid: uuid)
    if @user && @user.update(params[:user])
      redirect to("/users/#{@user.id}")
    else
      status 400
      "Error: Failed to update user."
    end
  end

  # Delete
  delete '/users/:id' do
    uuid = request.cookies['user_uuid']
    @user = User.find_by(uuid: uuid)
    if @user && @user.destroy
      response.delete_cookie('user_uuid')
      redirect to('/users')
    else
      status 404
      "Error: No user found with the provided UUID, or failed to delete user."
    end
  end
end
