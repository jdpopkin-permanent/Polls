class CreateAnswerResponsesTable < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.integer :respondent_id
      t.integer :answer_choice_id
      t.timestamps
    end
  end
end
