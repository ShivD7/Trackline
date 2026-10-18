class Company < ApplicationRecord
  belongs_to :user
  has_many :job_applications, dependent: :restrict_with_error

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :user_id }
  validates :website, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true

  scope :alphabetical, -> { order(Arel.sql("lower(name) ASC")) }

  def self.search(term)
    return all if term.blank?

    pattern = "%#{sanitize_sql_like(term.strip)}%"
    where("name LIKE :pattern OR industry LIKE :pattern OR headquarters LIKE :pattern", pattern:)
  end
end
