class Memo < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :age_group, presence: true
end
