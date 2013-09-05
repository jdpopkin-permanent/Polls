class Poll < ActiveRecord::Base
  attr_accessible :author_id, :title

  validates :author_id, presence: true


end