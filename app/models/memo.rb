class Memo < ApplicationRecord
  belongs_to :user

  validates :age_group, presence: true
end
