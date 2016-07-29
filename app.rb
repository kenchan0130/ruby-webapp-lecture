require 'sinatra/contrib'

require './models/post'

module MyApp
  class Application < Sinatra::Base
    configure do
      register Sinatra::ActiveRecordExtension
      set :database_file, 'config/database.yml'
    end

    configure :development do
      register Sinatra::Reloader
    end

    get '/' do
      'Hello Sinatra'
    end

    get '/posts' do
      @posts = Post.all
      erb :'posts/index'
    end

    get '/posts/new' do
      @post = Post.new
      erb :'posts/new'
    end

    post '/posts' do
      @post = Post.create!(title: params[:title], contents: params[:contents])
      erb :'posts/create'
    end
  end
end
