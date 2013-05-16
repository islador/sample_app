require 'spec_helper'

describe "UserPages" do

  subject { page }

  describe "Signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign up') }
    it { should have_selector('title', text: 'Sign up') }
  end

  describe "profile page" do
  	let(:user) { FactoryGirl.create(:user) }
  	before { visit user_path(user) }

  	it { should have_selector('h1', 	text: user.name) }
  	it { should have_selector('title', 	text: user.name) }
  end

  describe "signup" do

  	before { visit signup_path }

  	let(:submit) { "Create my account" }

  	describe "with invalid information" do
  		it "should not create a user" do
  			expect { click_button submit }.not_to change(User, :count)
  		end
      it "should have error" do
        expect { should have_content('error') }
      end
  	end

  	describe "with valid information" do
  		before do
  			fill_in "Name",			with: "Example User"
  			fill_in "Email",		with: "user@example.com"
  			fill_in "Password",		with: "foobar"
  			fill_in "confirmation",	with: "foobar"
  		end

  		it "should create a user" do
  			expect { click_button submit }.to change(User, :count).by(1)
  		end

      it "should not have content 'error'" do
        expect { should_not have_content('error') }
      end
  	end

    describe "suceeds" do
      before do #create user
        fill_in "Name",     with: "Example User"
        fill_in "Email",    with: "user@example.com"
        fill_in "Password",   with: "foobar"
        fill_in "confirmation", with: "foobar"
        click_button submit
      end

      #find user
      let(:user) {User.find_by_email('user@example.com')}

      #test user page for title, alert box and h1 content
      it {should have_selector('title', text: user.name)}
      it {should have_selector('div.alert.alert-success', text: 'Welcome to the Sample App!')}
      it {should have_selector('h1',  text: user.name)}
    end
  end
end