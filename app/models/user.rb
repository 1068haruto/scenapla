class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  
  validates :email, presence: true, uniqueness: true, 
            format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "は有効なメールアドレスである必要があります" }
  validates :password, presence: true, length: { in: 8..128 }, 
            format: { with: /(?=.*[a-z])(?=.*\d)/, message: "は小文字と数字を含める必要があります" }, if: :password_present?
  validates :password_confirmation, presence: true, if: :password_present?

  def password_present?
    password.present?
  end
end
