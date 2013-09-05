class AnswerChoice < ActiveRecord::Base
  attr_accessible :text, :question_id

  validates :text, :question_id, presence: true
end