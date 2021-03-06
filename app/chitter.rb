ENV['RACK_ENV'] ||= 'development'
require 'sinatra/base'
require_relative 'data_mapper_setup'
require 'sinatra/flash'
require './lib/chathandler.rb'

class Chitter < Sinatra::Base
  enable :sessions
  set :session_secret, 'session'
  register Sinatra::Flash
  include ChatHandler

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end
  end

  get '/' do
    erb :signin
  end

  post '/' do
    user = User.authenticate(params[:username_or_email], params[:password])
    if !!user
      session[:user_id] = user.id
      redirect '/chat'
    else
      redirect '/'
    end
  end

  get '/chat' do
    @peeps = Chitter.peeps
    @current_user = current_user
    erb :chat
  end

  post '/chat' do
    if current_user
      #tag_count = Tag.count
      peep = Chitter.create_peep(params[:peep], current_user)
      Chitter.tags(peep)
      #Chitter.notify_tagged_users(peep) if Tag.count > tag_count
    else
      flash[:no_user] = "If you wanna get peepin' you need to"
    end
    redirect '/chat'
  end

  get '/signup' do
    erb :signup
  end

  post '/signup' do
    user = Chitter.create_user(params)
    session[:user_id] = user.id if user.valid?
    flash[:errors] = user.errors.values.flatten
    flash[:email] = user.email
    flash[:name] = user.name
    redirect(user.valid? ? '/chat' : '/signup')
  end

  get '/signout' do
    session[:user_id] = nil
    redirect '/'
  end

  run! if app_file == $0
end
