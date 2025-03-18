class AiAdvice < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :content, :real_scenario_updated_at, presence: true
end
