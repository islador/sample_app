module SessionsHelper

	def sign_in(user)
		remember_token = User.new_remember_token
		cookies.permanent[:remember_token] = remember_token
		user.update_attribute(:remember_token, User.encrypt(remember_token))
		self.current_user = user
	end

	def current_user=(user)
		@current_user = user
	end

	def current_user?(user)
		user == current_user
	end

	def current_user
		remember_token = User.encrypt(cookies[:remember_token])
		@current_user ||= User.find_by_remember_token(remember_token)
	end

	def signed_in?
		!current_user.nil?
	end

	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)
	end

	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)
	end

	def store_location
		if signed_in? # added for 9.6.8
			session[:return_to] = user_path(current_user) #changed 'current_user' as that was
			# passing the user model in the session and causing a CookieOverload error.
		else
			session[:return_to] = request.url
		end
	end

	def signed_in_user
		store_location
		redirect_to signin_url, notice: "Please sign in" unless signed_in?
	end
end
