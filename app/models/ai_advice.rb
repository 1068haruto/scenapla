class AiAdvice < ApplicationRecord
  belongs_to :user
  validates :content, presence: true
  validates :real_scenario_updated_at, presence: true
end
