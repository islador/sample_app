require 'spec_helper'

describe RelationshipsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in user }

  describe "creating a relationship with Ajax" do #, :js => true do #

    it "should increment the Relationship count" do
      expect do
        #sign_in user
        visit user_path(other_user)
        #xhr :post, relationships_path, relationship: { followed_id: other_user.id }
        #xhr :post, :create, relationship: { followed_id: other_user.id } 
        # xhr was not working as per
        # http://stackoverflow.com/questions/16507012/im-learning-rails-with-m-hartls-tutorial-ch-11-2-5-and-got-this-error-in-te
        # I attempted both page.execute_script() and xhr :post, relationships_path
        # I failed to find and understand the syntax for page.execute_script and
        # I failed to understand which path xhr was to be pointed at this lead me to
        # read the capybara documentation at http://rubydoc.info/github/jnicklas/capybara/master#Asynchronous_JavaScript__Ajax_and_friends_
        # and realize I could test the javascript functions merely by clicking the buttons.
        #xml_http_request :post, :create, relationship: { followed_id: other_user.id }
        #page.execute_script("$('follow_form')")
        click_button("Follow")
        #page.execute_script("$Ajax({type:'POST', url:'/relationships/'+other_user.id})")
        #page.click_on('Follow')
      end.to change(Relationship, :count).by(1)
    end

    it "should respond with success" do
      visit user_path(other_user)
      click_button("Follow")
      #xhr :post, :create, relationship: { followed_id: other_user.id }
      response.should be_success
    end
  end

  describe "destroying a relationship with Ajax" do

    before { user.follow!(other_user) }
    let(:relationship) { user.relationships.find_by_followed_id(other_user) }

    it "should decrement the Relationship count" do
      expect do
        visit user_path(other_user)
        #xhr :delete, relationships_path(relationship.id), id: relationship.id
        #xhr(:delete, :destroy, id: relationship.id)
        #xml_http_request :delete, :destroy, id: relationship.id
        click_button("Unfollow")
      end.to change(Relationship, :count).by(-1)
    end

    it "should respond with success" do
      visit user_path(other_user)
      #xhr :delete, :destroy, id: relationship.id
      click_button("Unfollow")
      response.should be_success
    end
  end
end