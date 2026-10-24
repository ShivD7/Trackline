require "fileutils"
require "securerandom"

module Trackline
  class LocalMailDelivery
    attr_accessor :settings

    def initialize(settings = {})
      @settings = settings
    end

    def deliver!(mail)
      FileUtils.mkdir_p(settings.fetch(:location))
      path = File.join(settings.fetch(:location), "reset-#{Time.now.utc.strftime('%Y%m%d-%H%M%S')}-#{SecureRandom.hex(4)}.txt")
      File.write(path, "To: #{mail.to.join(', ')}\nSubject: #{mail.subject}\n\n#{mail.text_part.body.decoded}", mode: "w", perm: 0o600)
    end
  end
end
