Given /^a user visits the signin page$/ do
	visit signin_path
end

When /^he submits invalid signin information$/ do
	click_button "Sign In" #click button seems to work fine up here
end

Then /^he should see an error message$/ do

	#expect(page).to have_selector('div.alert.alert-error') #reccomended
	expect(page).to have_selector('div.alert.alert-error',
	 text: "Invalid email/password combination") # overly verbose
end

Given /^the user has an account$/ do
	#visit signin_path
	@user = User.create(name: "Example User", email: "user@example.com",
		password: "Foobar", password_confirmation: "Foobar")
end

When /^the user submits valid signin information$/ do
	fill_in "Email",	with: @user.email
	fill_in "Password",	with: @user.password
	click_button "Sign In"
end

Then /^he should see his profile page$/ do
  expect(page).to have_selector('title', text: @user.name)
end

Then /^he should see a signout link$/ do
  expect(page).to have_link('Sign out', href: signout_path)
end