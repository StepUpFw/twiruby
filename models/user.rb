require 'mongoid'
require 'bcrypt'

	class User
		include Mongoid::Document #データベース

		#フィールドを用意
		field :name
		field :email
		field :password_hash
		field :password_salt

		attr_readonly :password_hash, :password_salt #新しいレコードを作成

		#各自条件に適切であるか。
		validates :mane, presence: true #[presence] 値が空でないか
		validates :name, unqueness: true #[unqueness] 値が一意であるか
		validates :email, unqueness: true
		validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create } #[format] 正規表現パターンに一致しているか
		validates :email, presence: true
		validates :password_hash, confirmation: true #２つのフィールドが等しい
		validates :password_hash, presence: true
		validates :password_salt, presence: true

		#パスワードを暗号化
		def encrypt_password(password)
			if password.present? #真偽判定 nil, "", " "(半角スペース), [](空配列), {}(空ハッシュ) のときにfalse
				self.password_salt = BCrypt::Engine.generate_salt #[generate_salt] 与えられた計算コストでランダムなsalt値を生成
				self.password_hash = BCrypt::Engine.hash_secret(password, password_salt) #[hash_secret]　passと有効なsaltを与えパスワードハッシュを計算
			end
		end

		#ユーザー認証
		def self.authenticate(email, passwood)
			user = self.where(email: email).first　###よく分からない
			if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt) ##照らし合わせ...?
				user
			else
				nil
			end
		end
	end-