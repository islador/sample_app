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

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in(user)
      visit edit_user_path(user)
     end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_selector('title', text: "Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",        with: new_name
        fill_in "Email",       with: new_email
        fill_in "Password",       with: user.password
        fill_in "Password confirmation",        with: user.password
        click_button "Save changes"
      end

      it { should have_selector('title',  text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end
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

      describe "after submission" do
        before { click_button submit }

        it { should have_selector('title', text: 'Sign up') }
        it { should have_content("The form contains 6 errors")}
        it { should have_content('error') }
        it { should have_content("Password can't be blank") }
        it { should have_content("Name can't be blank")}
        it { should have_content("Email can't be blank")}
        it { should have_content("Email is invalid")}
        it { should have_content("Password is too short (minimum is 6 characters")}
        it { should have_content("Password confirmation can't be blank")}
      end
  	end

  	describe "with valid information" do
  		before do
        valid_signup
  		end

  		it "should create a user" do
  			expect { click_button submit }.to change(User, :count).by(1)
  		end

      it "should not have content 'error'" do
        expect { should_not have_content('error') }
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) {User.find_by_email('user@example.com') }

        it { should have_link('Sign out') }
        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
  	end

    describe "verbose password confirmation blank error test" do
      before do #create user
        fill_in "Name",   with: "Example User"
        fill_in "Email",    with: "user@verboseerror.com"
        fill_in "Password",   with: "verbose-error"
        click_button submit
      end
      it {should have_content("The form contains 2 errors")}
      it {should have_content("Password confirmation can't be blank")}
    end

    describe "verbose password blank error test" do
      before do #create user
        fill_in "Name",   with: "Example User"
        fill_in "Email",    with: "user@verboseerror.com"
        fill_in "confirmation",   with: "verbose-error"
        click_button submit
      end
      it {should have_content("The form contains 3 errors")}
      it {should have_content("Password can't be blank")}
      it {should have_content("Password doesn't match confirmation")}
    end

    describe "verbose email blank error test" do
      before do #create user
        fill_in "Name",   with: "Example User"
        fill_in "Password",   with: "verbose-error"
        fill_in "confirmation",   with: "verbose-error"
        click_button submit
      end
      it {should have_content("The form contains 2 errors")}
      it {should have_content("Email can't be blank")}
      it {should have_content("Email is invalid")}
    end

    describe "verbose name blank error test" do
      before do #create user
        fill_in "Email",    with: "user@verboseerror.com"
        fill_in "Password",   with: "verbose-error"
        fill_in "confirmation",   with: "verbose-error"
        click_button submit
      end
      it {should have_content("The form contains 1 error")}
      it {should have_content("Name can't be blank")}
    end

    describe "verbose password/confirmation mismatch error test" do
      before do #create user
        fill_in "Name",   with: "Meowmix"
        fill_in "Email",    with: "user@verboseerror.com"
        fill_in "Password",   with: "verbose-error1"
        fill_in "confirmation",   with: "verbose-error2"
        click_button submit
      end
      it {should have_content("The form contains 1 error")}
      it {should have_content("Password doesn't match confirmation")}
    end

    describe "verbose password length error test" do
      before do #create user
        fill_in "Name",   with: "WildJack"
        fill_in "Email",    with: "user@verboseerror.com"
        fill_in "Password",   with: "error"
        fill_in "confirmation",   with: "error"
        click_button submit
      end
      it {should have_content("The form contains 1 error")}
      it {should have_content("Password is too short (minimum is 6 characters")}
    end

    describe "verbose email validation error test" do
      before do #create user
        fill_in "Name",   with: "WildJack"
        fill_in "Email",    with: "userverboseerrorcom"
        fill_in "Password",   with: "error1"
        fill_in "confirmation",   with: "error1"
        click_button submit
      end
      it {should have_content("The form contains 1 error")}
      it {should have_content("Email is invalid")}
    end

    describe "suceeds" do
      before do #create user
        valid_signup
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