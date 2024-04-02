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
      redirect to("/users/#{@user.id}")
    else
      # TODO: handle error
    end
  end

  # Read
  get '/users/:id' do
    @user = User.find(params[:id])
    # TODO: render game stats view
  end

  # Update
  put '/users/:id' do
    @user = User.find(params[:id])
    if @user.update(params[:user])
      redirect to("/users/#{@user.id}")
    else
      # TODO: handle error
    end
  end

  # Delete
  delete '/users/:id' do
    @user = User.find(params[:id])
    @user.destroy
    redirect to('/users')
  end
end
