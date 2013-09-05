class Question < ActiveRecord::Base
  attr_accessible :text, :poll_id

  validates :text, :poll_id, presence: true
end