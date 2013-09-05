class Response < ActiveRecord::Base
  attr_accessible :respondent_id, :answer_choice_id

  validates :respondent_id, :answer_choice_id, presence: true
end