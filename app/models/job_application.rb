class JobApplication < ApplicationRecord
  STATUSES = %w[wishlist applied screening interviewing offer rejected withdrawn].freeze
  ACTIVE_STATUSES = %w[applied screening interviewing offer].freeze
  TERMINAL_STATUSES = %w[rejected withdrawn].freeze
  PRIORITIES = %w[low medium high].freeze
  WORK_MODES = %w[remote hybrid onsite].freeze

  belongs_to :company
  has_many :notes, -> { order(occurred_on: :desc, created_at: :desc) }, dependent: :destroy
  has_many :stage_changes, -> { order(changed_at: :desc) }, dependent: :destroy

  enum :status, STATUSES.index_with(&:itself), default: :wishlist, validate: true
  enum :priority, PRIORITIES.index_with(&:itself), default: :medium, validate: true

  validates :role_title, presence: true, length: { maximum: 120 }
  validates :work_mode, inclusion: { in: WORK_MODES }, allow_blank: true
  validates :contact_email, format: URI::MailTo::EMAIL_REGEXP, allow_blank: true
  validates :job_url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true
  validate :applied_date_matches_status

  scope :recent_first, -> { order(updated_at: :desc) }
  scope :active, -> { where(status: ACTIVE_STATUSES) }
  scope :follow_up_due, -> { active.where(follow_up_on: ..Date.current) }
  scope :upcoming_follow_ups, -> { active.where(follow_up_on: Date.current..14.days.from_now.to_date) }
  scope :stale, -> { active.where(updated_at: ...14.days.ago) }

  def self.search(term)
    return all if term.blank?

    pattern = "%#{sanitize_sql_like(term.strip)}%"
    joins(:company).where(
      "job_applications.role_title LIKE :pattern OR companies.name LIKE :pattern OR job_applications.location LIKE :pattern",
      pattern: pattern
    )
  end

  def active?
    status.in?(ACTIVE_STATUSES)
  end

  def terminal?
    status.in?(TERMINAL_STATUSES)
  end

  def overdue?
    active? && follow_up_on.present? && follow_up_on < Date.current
  end

  def stale?
    active? && updated_at < 14.days.ago
  end

  private

  def applied_date_matches_status
    return if wishlist? || applied_on.present?

    errors.add(:applied_on, "is required once an application leaves the wishlist")
  end
end
