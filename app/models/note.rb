class Note < ApplicationRecord
  belongs_to :job_application, touch: true

  validates :body, presence: true, length: { maximum: 2_000 }
  validates :occurred_on, presence: true
end
