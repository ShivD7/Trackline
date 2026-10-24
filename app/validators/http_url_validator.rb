class HttpUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    uri = URI.parse(value)
    return if uri.is_a?(URI::HTTP) && uri.host.present? && uri.userinfo.nil?

    record.errors.add(attribute, "must be a complete http:// or https:// address")
  rescue URI::InvalidURIError
    record.errors.add(attribute, "must be a complete http:// or https:// address")
  end
end
