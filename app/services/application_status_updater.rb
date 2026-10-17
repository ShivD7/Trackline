class ApplicationStatusUpdater
  def self.call(application:, attributes:)
    new(application, attributes).call
  end

  def initialize(application, attributes)
    @application = application
    @attributes = attributes
  end

  def call
    previous_status = application.status

    ApplicationRecord.transaction do
      application.update!(attributes)
      record_stage_change(previous_status) if application.saved_change_to_status?
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  attr_reader :application, :attributes

  def record_stage_change(previous_status)
    application.stage_changes.create!(
      from_status: previous_status,
      to_status: application.status,
      changed_at: Time.current
    )
  end
end
