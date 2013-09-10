require 'spec_helper'

describe "Authentication" do 
	subject { page }

	describe "signin page" do
		before { visit signin_path }

		it { should have_content('Sign in') }
		it { should have_selector('title', text: 'Sign In') }
	end

	describe "signin" do
		before {visit signin_path}

		describe "without logged in user" do # Tests for 9.6.3
			it { should_not have_link('Profile') }
			it { should_not have_link('Settings') }
		end

		describe "with invalid information" do
			before { click_button 'Sign In' }

			it { should have_selector('title', text: 'Sign In') }
			it { should have_selector('div.alert.alert-error', text: 'Invalid') }

			describe "after visiting another page" do
				before { click_link "Home" }
				it { should_not have_selector('div.alert.alert-error') }
			end
		end

		describe "with valid information" do
			let(:user) { FactoryGirl.create(:user) }
			before do
				valid_signin(user)
			end

			it { should have_selector('title', text: user.name)}
			it { should have_link('Users',	href: users_path) }
			it { should_not have_link('Sign in',	href: signin_path) }
			it { should have_link('Sign out',		href: signout_path) }
			it { should have_link('Profile',		href: user_path(user))}
			it { should have_link('Settings',	href: edit_user_path(user))}

			describe "followed by signout" do
				before { click_link "Sign out" }
				it { should have_link('Sign in') }
			end
		end	
	end

	describe "authorization" do

		describe "as non-admin user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:non_admin) { FactoryGirl.create(:user) }

			before { sign_in non_admin, no_capybara: true }

			describe "submitting a DELETE request to the Users#destroy action" do
				before { delete user_path(user) }
				specify { expect(response).to redirect_to(root_url) }
			end
		end

		describe "as an admin user" do # Exercise 9.6.9
			let(:user) {FactoryGirl.create(:user) }
			let(:admin) {FactoryGirl.create(:admin) }

			before { sign_in admin, no_capybara: true }

			describe "submitting a DELETE request targeting an admin to the Users#destroy action" do
				before { delete user_path(admin) }
				#it { should have_selector('h1', text: 'Welcome to the Sample App')}
				#it {should have_selector('div.alert alert-error',	text: 'Admins cannot be deleted.')}
				#it { should_not have_selector('title', text: 'Sign up') }
				specify { response.should redirect_to(root_url), 
                  flash[:error].should =~ /Admins cannot be deleted./i } # http://stackoverflow.com/questions/9956523/ruby-tutorial-ch9-exercise-9-dont-allow-admin-to-delete-themselves
			end
		end
		

		describe "for non-signed-in users" do
			let(:user) { FactoryGirl.create(:user) }

			
	        describe "in the Microposts controller" do

		        describe "submitting to the create action" do
		          before { post microposts_path }
		          specify { expect(response).to redirect_to(signin_path) }
		        end

		        describe "submitting to the destroy action" do
		          before { delete micropost_path(FactoryGirl.create(:micropost)) }
		          specify { expect(response).to redirect_to(signin_path) }
		        end
		    end

			describe "when attempting to visit a protected page" do
				before do
					visit edit_user_path(user)
					sign_in(user)
				end

				describe "after signing in if they have access" do

					it "should render the desired protected page" do
						expect(page).to have_selector('title',	text: 'Edit user')
					end

					describe "when signing in again" do # added for 9.6.8
			            before do
			              delete signout_path
			              visit signin_path
			              sign_in(user)
			            end

			            it "should render the default (profile) page" do
			            	expect(page).to have_selector('title',	text: user.name)
			            	#expect(page).to have_selector('h1',	text: 'Welcome to the Sample App')
			            end
			        end
				end
			end

			describe "in the Users controller" do

				describe "visiting the edit page" do
					before { visit edit_user_path(user) }

					it { should have_selector('title',	text: 'Sign In') }
				end

				describe "submitting to the update action" do
					before { put user_path(user) }
					specify { expect(response).to redirect_to(signin_path) }
				end

				describe "visiting the user index" do
					before { visit users_path }
					it { should have_selector('title',	text: 'Sign In') }
				end

				describe "visiting the user's profile" do # tests that users must be signed in to view user profiles.
					before { visit user_path(user)}
					it { should have_selector('title',	text: 'Sign In') }
					it { should have_selector('div.alert.alert-error',	text: "Please sign in to view user profiles.")}
				end
			end
		end

		describe "as wrong user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
			before { sign_in user, no_capybara: true}

			describe "visiting Users#edit page" do
				before { visit edit_user_path(wrong_user) }
				it { should_not have_selector('title',	text: 'Edit user')}
			end

			describe "submitting a PUT request to the Users#update action" do
				before { put user_path(wrong_user) }
				specify {expect(response).to redirect_to(root_url) }
			end
		end

		describe "for non-signed-in users" do
			let(:user) { FactoryGirl.create(:user) }

			describe "when attempting to visit a protected page" do
				before do
					visit edit_user_path(user)
					fill_in "Email",	with: user.email
					fill_in "Password",	with: user.password
					click_button "Sign In"
				end

				describe "after signing in" do

					it "should render the desired protected page" do
						expect {page.to have_selector('title',	text: 'Edit user')}
					end
				end
			end
		end
	end
end