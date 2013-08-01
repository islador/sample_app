class SessionsController < ApplicationController

	def new
	end

	def create
		user = User.find_by(email: params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
			#sign the user in and redirect to the user's show page.
		else
			# Create an error messageand re-render the signin form.
		end
	end

	def destroy
	end
	
end
