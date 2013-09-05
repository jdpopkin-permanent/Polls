class User < ActiveRecord::Base
  attr_accessible :user_name
  #attr_reader :id

  validates :user_name, presence: true, uniqueness: true

  has_many(
    :authored_polls,
    class_name: "Poll",
    foreign_key: :author_id,
    primary_key: :id
    )

  has_many(
  :responses,
  class_name: "Response",
  foreign_key: :respondent_id,
  primary_key: :id
  )

    #polls where we've answered at least one question
    #want: polls where all their questions
    #...have at least one answer choice
    #...with a response from our user


  has_many :answer_choices, through: :responses, source: :answer_choice
  has_many :questions, through: :answer_choices, source: :question
  has_many :completed_polls, through: :questions, source: :poll, uniq: true,
  conditions: proc {"(SELECT
        COUNT(*) AS num_questions
        FROM
        polls AS p
        JOIN
        questions
        ON
        p.id = questions.poll_id
        WHERE
        p.id = polls.id) = (
        SELECT
        COUNT(*) AS num_questions
        FROM
        polls AS p
        JOIN
        questions
        ON
        p.id = questions.poll_id
        JOIN
        answer_choices
        ON
        answer_choices.question_id = questions.id
        JOIN
        responses
        ON
        responses.answer_choice_id = answer_choices.id
        WHERE
        p.id = polls.id AND responses.respondent_id = '#{id}')"}

        has_many :incomplete_polls, through: :questions, source: :poll, uniq: true,
        conditions: proc {"(SELECT
              COUNT(*) AS num_questions
              FROM
              polls AS p
              JOIN
              questions
              ON
              p.id = questions.poll_id
              WHERE
              p.id = polls.id) <> (
              SELECT
              COUNT(*) AS num_questions
              FROM
              polls AS p
              JOIN
              questions
              ON
              p.id = questions.poll_id
              JOIN
              answer_choices
              ON
              answer_choices.question_id = questions.id
              JOIN
              responses
              ON
              responses.answer_choice_id = answer_choices.id
              WHERE
              p.id = polls.id AND responses.respondent_id = '#{id}')"}

  def num_questions_for_poll
    Poll.find_by_sql(<<-SQL)
      SELECT
        COUNT(*) AS num_questions
        FROM
        polls
        JOIN
        questions
        ON
        polls.id = questions.poll_id
        WHERE
        polls.id = poll.id
    SQL
  end

  def num_answered_questions
    Poll.find_by_sql(<<-SQL)
      SELECT
        COUNT(*) AS num_questions
        FROM
        polls
        JOIN
        questions
        ON
        polls.id = questions.poll_id
        JOIN
        answer_choices
        ON
        answer_choices.question_id = questions.id
        JOIN
        responses
        ON
        responses.answer_choice_id = answer_choices.id
        WHERE
        polls.id = poll.id AND responses.respondent_id = #{self.id}
    SQL

  end

  def sql_test
    Poll.find_by_sql(<<-SQL)
    SELECT
    polls.*
    FROM
    polls
    JOIN
    questions
    ON
    questions.poll_id = polls.id
    JOIN
    answer_choices
    ON
    answer_choices.question_id = questions.id
    JOIN
    responses
    ON
    responses.answer_choice_id = answer_choices.id
    WHERE
    #{id} = responses.respondent_id AND #{id}
    (
      SELECT
        COUNT(*)
      FROM
        responses
      JOIN
        answer_choices
      ON
        responses.answer_choice_id = answer_choices.id
      JOIN
        questions
      ON
        questions.id = answer_choices.question_id
      JOIN
        polls
      ON
        polls.id = questions.poll_id
      GROUP BY
      questions.id


    )
    = 3
    SQL
  end

  def sql_test_number_of_answered_questions
    Poll.find_by_sql(<<-SQL)
      SELECT
        questions.text, COUNT(*) as answered_questions
      FROM
        responses
      JOIN
        answer_choices
      ON
        responses.answer_choice_id = answer_choices.id
      JOIN
        questions
      ON
        questions.id = answer_choices.question_id
      JOIN
        polls
      ON
        polls.id = questions.poll_id
      GROUP BY
      questions.id

    SQL
  end

  def uncompleted_polls
    Poll.all - self.completed_polls
  end
end