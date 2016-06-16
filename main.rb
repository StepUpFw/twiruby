require 'sinatra'
require 'sinatra/reloader'

get '/' do
  erb :index # :indexの部分はviewsの下に作ったファイル名に合わせる
end