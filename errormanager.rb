user.errors.full_messages.each do |msg|
	if msg.to_s == "Password is too short (minimum is 6 characters)" && 
		user.errors.get(:password_digest) == "can't be blank)
		else
			msg
		end
	end
end