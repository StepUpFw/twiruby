require 'sinatra/base'
require 'haml'

require_relative 'models/user' #相対パス

class Server < Sinatra::Base

	enable :sessions #セッションを有効に
	set :session_secret, "My session secret" #秘密鍵

	#ログインフォーム *Login form
	get '/log_in' do
		if session[:user_id] #セッションが残っていればLogout formへ
			redirect '/log_out'
		end

		haml :log_in
	end

	#ログアウトフォーム
	get '/log_out' do
		unless session[:user_id] #セッションが存在しなければLogin formへ
			redirect '/log_in'
		end

		haml :log_out
	end

	#アカウント作成 *singn_up form
	get '/sign_up' do
		session[:user_id] ||= nil
		if session[:user_id]　#前回までのセッションが残っていたらLogout formへ
			redirect '/log_out' #Logout form
		end

		haml :sign_up
	end

	#ログアウト処理
	delete '/session' do
		session[:user_id] = nil #セッションを空にし、ログインフォームへ
		redirect '/log_in'
	end

	#ログイン処理
	post '/session' do
		if session[:user_id] #セッションが残っていればユーザー情報のページへ
			redirect "/users"
		end

		user = User.authenticate(params[:email], params[:password]) #ユーザー認証
		if user　#取得できたら、セッションを作成しユーザー情報ページへ
			session[:user_id] = user._id
			redirect "/users"
		else
			redirect "/log_in"
		end
	end

	#アカウント作成処理
	post '/users' do
		if params[:password] != params[:confirm_password]　#passwordが確認用passwordと不一致ならsign_up formへ
			redirect "/sign_up" #singn_up form
		end

		user = User.new(email: params[:email], name: params[:name]) #インスタンスを新規作成
		user.encrypt_password(params[:password]) #暗号化
		if user.save!
			session[:user_id] = user._id
			redirect "/users" #ユーザー情報のページへリダイレクト
		else
			redirect "/sign_up"
		end
	end



	#ユーザー情報ページ
	get '/users' do
		@user = User.where(_id: session[:user_id]).first
		if @user #セッションが存在すれば表示される
			haml :dashboard
		else
			redirect '/log_in'
		end
	end
end