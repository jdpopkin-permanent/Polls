class Question < ActiveRecord::Base
  attr_accessible :text, :poll_id

  validates :text, :poll_id, presence: true

  belongs_to(
    :poll,
    class_name: "Poll",
    foreign_key: :poll_id,
    primary_key: :id
  )

  has_many(
    :answer_choices,
    class_name: "AnswerChoice",
    foreign_key: :question_id,
    primary_key: :id,
    dependent: :destroy
  )


  #has_many :sibling_questions, through: :poll, source: :questions, condition: ""

  has_many :sibling_questions, through: :poll, source: :questions,
    conditions: "poll_id = questions.poll_id"

  def results
    answer_choices = self.answer_choices.includes(:responses)

    question_results = {}

    answer_choices.each do |answer_choice|
      question_results[answer_choice.text] = answer_choice.responses.length
    end

    question_results


    # self.answer_choices
#     .select("answer_choices.*, COUNT(*) AS answer_choice_count")
#     .joins("LEFT OUTER JOIN responses ON answer_choices.id = responses.answer_choice_id")
  end

  def results_with_join
    answer_choices = self.answer_choices
    .select("answer_choices.*, COUNT(*) AS answer_choice_count")
    .joins("LEFT OUTER JOIN responses ON answer_choices.id = responses.answer_choice_id")
    .group("answer_choices.id")

    question_results = {}

    answer_choices.each do |answer_choice|
      question_results[answer_choice.text] = answer_choice.answer_choice_count
    end

    question_results

  end

end