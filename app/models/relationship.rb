class Relationship < ActiveRecord::Base
  attr_accessible :followed_id

  #added in 11.1.2
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  #added in 11.1.3
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
