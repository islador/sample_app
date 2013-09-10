require 'spec_helper'

describe Micropost do
	let(:user) {FactoryGirl.create(:user) }
	before do
		#This code is not idiomatically correct.
		@micropost = Micropost.new(content: "Lorem ipsum", user_id: user.id)
		#Answer: it's not right because it's creating a single piece of content instead
		# of dynamic content?
	end

	subject { @micropost }

	it { should respond_to(:content) }
	it { should respond_to(:user_id) }
	it { should respond_to(:user) }
	its(:user) { should eq user }


	it { should be_valid }

	describe "when user id is not present" do
		before { @micropost.user_id = nil }
		it { should_not be_valid }
	end
end
