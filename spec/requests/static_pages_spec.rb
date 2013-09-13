require 'spec_helper'

describe "StaticPages" do

  subject { page }

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Home"
    click_link "Sign up Now!"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "sample app"
    page.should have_selector 'title', text: full_title('')
  end
  
  describe "Home page" do
    before { visit root_path }
    
    it { should have_selector('h1', text: 'Sample App') }
    it { should have_selector('title', text: full_title('')) }
    it { should_not have_selector('title', text: '| Home') }

    describe "for signed-in users" do
      let(:user) {FactoryGirl.create(:user) }
      before do
        2.times {FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")}
        #FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end

      it "should have the proper micropost count in the sidebar" do #added for 10.5.1
        page.should have_selector('postcount', text: user.microposts.count.to_s)
      end

      describe "micropost sidebar pluralization tests" do #added for 10.5.1
        # note: describe blocks are not sandboxed.
        let(:user2) {FactoryGirl.create(:user) } #switch to user2
        before do
          sign_in user2
        end

        it "should have the proper pluralization for one post" do
          FactoryGirl.create(:micropost, user: user2, content: "Meowmix")
          visit root_path
          page.should have_selector('postcount', text: '1 micropost')
          #page.should have_selector('postcount', text: 'micropost'.pluralize(user2.microposts.count.to_s))
        end

        it "should have the proper pluralization for two posts" do
          3.times{FactoryGirl.create(:micropost, user: user2, content: "Meowmix")}
          visit root_path
          page.should have_selector('postcount', text: '3 microposts')
          page.should have_selector('postcount', text: 'micropost'.pluralize(user2.microposts.count.to_s))
        end
      end

      describe "microposts should paginate" do
        before (:all) do
          30.times{FactoryGirl.create(:micropost, user: user, content: "Meowmix")}
          visit root_path
        end
        after(:all) {user.microposts.delete_all}

        #visit root_path
        it {should have_selector('postcount', text: '32 microposts')}
        it {should have_selector('div.pagination')}
        it {should have_link('2', href: '/?page=2')}
      end
      #it {should have_selector('postcount', text: '2 microposts')} # test for after(:all)
    end
  end
  
  describe "Help page" do
    before { visit help_path }

    it { should have_selector('h1', text: 'Help') }
    it {should have_selector('title', text: full_title('Help')) }
  end
  
  describe "About page" do
    before { visit about_path}

    it { page.should have_selector('h1', text: 'About') }
    it { page.should have_selector('title', text: full_title('About Us')) }
  end
  
  describe "Contact page" do
    before { visit contact_path }

    it { page.should have_selector('h1', text: 'Contact') }
    it { should have_selector('title', text: full_title('Contact')) }
  end
end
