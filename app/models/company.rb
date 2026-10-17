class Company < ApplicationRecord
  has_many :job_applications, dependent: :restrict_with_error

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :website, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true

  scope :alphabetical, -> { order(Arel.sql("lower(name) ASC")) }
end
