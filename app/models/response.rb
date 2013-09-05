# class UnansweredValidator < ActiveModel::EachValidator
#   def validate_each(record, attribute_name, value)
#     # r = Response.where("respondent_id = ?", value)
#
#     r = Response.find_by_respondent_id(value)
#     existing_responses = r.existing_responses
#
#     if existing_responses.length > 1
#       already_answered_error(record, attribute_name)
#     elsif existing_responses.length == 1
#       unless existing_responses.first.id == r.id
#         already_answered_error(record, attribute_name)
#       end
#     end
#   end
#
#   def already_answered_error(record, attribute_name)
#     record.errors[attribute_name] << "You've already answered this question."
#   end
#
# end

class Response < ActiveRecord::Base
  attr_accessible :respondent_id, :answer_choice_id

  validates :respondent_id, presence: true
  validates :answer_choice_id, presence: true
  validate :cannot_have_already_answered_question, :author_cannot_respond_to_own_poll

  belongs_to(
    :respondent,
    class_name: "User",
    foreign_key: :respondent_id,
    primary_key: :id
  )

  belongs_to(
    :answer_choice,
    class_name: "AnswerChoice",
    foreign_key: :answer_choice_id,
    primary_key: :id
  )

  protected

  def existing_responses
    Response.find_by_sql ["
    SELECT
      responses.*
    FROM
      responses
    JOIN
      answer_choices
    ON
      responses.answer_choice_id = answer_choices.id
    WHERE
      responses.respondent_id = ? AND
      answer_choices.question_id IN (
        SELECT
          question_id
        FROM
          answer_choices
        WHERE
          answer_choices.id = ?
      )", self.respondent_id, self.answer_choice_id]
  end

  private

  def author_cannot_respond_to_own_poll
    # can User be accessed here?
    # author = User.joins(:authored_polls).joins(:questions).joins(:answer_choices).where("answer_choices.id = ?", self.answer_choice_id)
    author = User.joins(authored_polls: {questions: :answer_choices}).where("answer_choices.id = ?", self.answer_choice_id)
    if author.first.id == respondent_id
      errors[:respondent_id] << "You can't answer your own question. Get a life!"
    end
  end

  def cannot_have_already_answered_question
    existing_responses = self.existing_responses

    if existing_responses.length > 1
      already_answered_error
    elsif existing_responses.length == 1
      unless existing_responses.first.id == self.id
        already_answered_error
      end
    end
  end


  def already_answered_error
    errors[:respondent_id] << "You've already answered this question."
  end

end