class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :companies, dependent: :destroy
  has_many :job_applications, through: :companies

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP },
    length: { maximum: 254 }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
end
