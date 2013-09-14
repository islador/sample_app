require 'spec_helper'

describe "UserPages" do

  subject { page }

  describe "index" do
    let(:user) {FactoryGirl.create(:user)}
    before do
      sign_in user
      visit users_path
    end

    it { should have_selector('title',  text: 'All users') }
    it { should have_content('All users') }

    describe "pagination" do
      
      before(:all)  {30.times {FactoryGirl.create(:user)} }
      after(:all) { User.delete_all }

      it { should have_selector('div.pagination') }


      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do
      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('delete')
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }

        #it "should not be able to delete other admins" do # attempt to add test for admin deleteing another admin.
         # let(:admin2) { FactoryGirl.create(:admin) }
          #before do
           # sign_in admin2
            #visit users_path
          #end
          #expect do
          #  click_link('delete')
          #end.not_to change(User, :count)
        #end
      end
    end
  end

  describe "Signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign up') }
    it { should have_selector('title', text: 'Sign up') }

  end

  describe "profile page" do
  	let(:user) { FactoryGirl.create(:user) }
    let!(:m1) {FactoryGirl.create(:micropost, user: user, content: "Foo")}
    let!(:m2) {FactoryGirl.create(:micropost, user: user, content: "Bar")}

  	before do
     sign_in(user)
     visit user_path(user)
   end

  	it { should have_selector('h1', 	text: user.name) }
  	it { should have_selector('title', 	text: user.name) }

    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end

    describe "microposts should paginate" do
      before (:all) do
        32.times{FactoryGirl.create(:micropost, user: user, content: "Meowmix")}
        visit user_path(user)
      end

      it {should have_selector('div.pagination')}
      it {should have_selector('title', text: user.name)}
      debugger
      it {should have_selector('h3', text: 'Microposts (32)')}
      #it {should have_selector('div.pagination')} # for some reason order
      #matters and this test breaks the h3 selector test above it.
      it {should have_link('2', href: '/users/' + user.id.to_s + '?page=2')} 

      after(:all) {user.microposts.delete_all}
    end

    describe "micropost delete links" do #added for 10.5.4
      let(:user) {FactoryGirl.create(:user) }
      let(:user2) {FactoryGirl.create(:user) }
      let(:m1) {FactoryGirl.create(:micropost, user: user2, content: "meowmix")}

      before do
        sign_in user
        visit user_path(user2)
      end

      it "should not be visible to other users" do
        should_not have_link('delete', href: '/microposts/' + m1.id.to_s)
      end

      it "should be visible to the creator" do
        sign_in user2
        visit user_path(user2)
        should have_link('delete', href: '/microposts/' + m1.id.to_s)
      end

      #it {should_not have_link('delete', href: '/microposts/' + m1.id.to_s)}
    end

    describe "user delete links" do
      it { should_not have_link('delete', href: user_path(user)) }

      describe "as an admin user" do
        let(:user) { FactoryGirl.create(:user) }
        let(:admin) { FactoryGirl.create(:admin) }

        before do
          sign_in admin
          visit user_path(user)
        end

        it {should have_link('delete', href: user_path(user))}
        
        it "should be able to delete another user" do
          expect do
            click_link('delete')
          end.to change(User, :count).by(-1)
        end
      end
    end
  end

  describe "profile page" do
    describe "micropost delete links" do
      let(:user) {FactoryGirl.create(:user) }
      let(:user2) {FactoryGirl.create(:user) }
      let(:m1) {FactoryGirl.create(:micropost, user: user2, content: "meowmix")}

      before do
        sign_in user
        visit user_path(user2)
      end

      it "should not be visible to other users" do
        should_not have_link('delete', href: '/microposts/' + m1.id.to_s)
      end

      #it {should_not have_link('delete', href: '/microposts/' + m1.id.to_s)}
    end
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

    #Stack Overflow resource 1 for 9.6.1
    #expect do
    #  @user.update_attributes(:admin => true)
    #end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    # Source: http://stackoverflow.com/questions/14618302/is-there-a-better-way-to-test-admin-security
    # failed to handle the error properly.

    #Stack Overflow resource 2 for 9.6.1
    #describe "accesible attributes" do 
    #  it "should not allow access to admin" do
    #    expect do
    #      User.new(admin: true) 
    #    end.should raise_error(ActiveModel::MassAssignmentSecurity::Error) #expect.should syntax is deprecated, so rewrote.
    #  end
    #end
    # Source: http://stackoverflow.com/questions/10748730/make-rails-class-attribute-inaccessible-rails-tutorial-chapter-9-exercise-1
    # worked, but contained deprecated expect syntax and acted upon User directly rather then the instanced user.

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password, password_confirmation: user.password} }
      end
      before do
        sign_in user, no_capybara: true
      end

      it "should trigger a MassAssignmentSecurity error" do
        expect do
          put user_path(user), params
        end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)

      end
    end

    describe "gravatar change link opens new tab" do #added for 9.6.2
      #it {should have_link('change', href: 'http://gravatar.com/emails', target: '_blank') }
      #it { should have_selector('a', :href => 'http://gravatar.com/emails', :target => '_blank', :content => 'change')}
      it { should have_selector("a[href='http://gravatar.com/emails'][target='_blank']") } # http://stackoverflow.com/questions/11313725/how-to-test-html-attributes-with-rspec
      # https://gist.github.com/them0nk/2166525 's explains the syntax for why this works.
      #click_link('change')
      #expect do
      #  click_link('change')
      #end.to open_new_tab
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

    describe "with signed in user" do #added tests for 9.6.6
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in(user)
        visit signup_path
      end

      it { should_not have_selector('title', text: 'Sign up') }
      #it { should have_selector('h1', text: 'Welcome to the Sample App')}
      it { should have_selector('div.alert.alert-error',  text: "You cannot sign up if you're already signed in.")}
      #expect {visit signup_path}.to redirect_to(users_path) # Various tests to tease out proper syntax.
      #visit signup_path should redirect_to(root_url)
    end

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
      #describe "with signed in user" do # tests for create page access for 9.6.6, failed to devise functional test.
       # let(:user) {FactoryGirl.create(:user) }
        #sign_in(user)
        #valid_signup

        #it { should_not have_selector('title', text: 'Sign up') }
        #it { should have_selector('h1', text: 'Welcome to the Sample App')}
        #it {should have_content("You cannot sign up if you're already signed in.")}
      #end

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