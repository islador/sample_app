# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base

  has_many :microposts, dependent: :destroy

  #added in 11.1.2
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  # note: 'dependent: :destroy' ensures that all relationships are destroyed when
  # the user is destroyed.

  #added in 11.1.4
  has_many :followed_users, through: :relationships, source: :followed

  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password

  before_save { |user| user.email = email.downcase }
  before_create :create_remember_token

  def feed
    Micropost.where("user_id = ?", id)
  end

  #Added in 11.1.4
  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end
  
  def User.new_remember_token
  	SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
  	Digest::SHA1.hexdigest(token.to_s)
  end

  private

  	def create_remember_token
  		self.remember_token = User.encrypt(User.new_remember_token)
  	end

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX}, 
  uniqueness: {case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true

end
