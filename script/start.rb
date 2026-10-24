require "rbconfig"
require "socket"
require "net/http"
require "fileutils"

root = File.expand_path("..", __dir__)
Dir.chdir(root)
ENV["RAILS_ENV"] = "development"
ENV["PORT"] ||= "3001"
port = Integer(ENV["PORT"], exception: false)
abort "PORT must be a number from 1024 to 65535." unless port && (1024..65535).cover?(port)
url = "http://127.0.0.1:#{port}"
ENV["TRACKLINE_URL"] ||= url
ENV["PIDFILE"] = File.join(root, "tmp/pids/server.pid")

def open_browser(url)
  return unless Gem.win_platform? && ENV["TRACKLINE_NO_BROWSER"] != "1"

  system("rundll32.exe", "url.dll,FileProtocolHandler", url)
end

begin
  TCPSocket.new("127.0.0.1", port).close
  response = Net::HTTP.start("127.0.0.1", port, open_timeout: 2, read_timeout: 2) { |http| http.get("/session/new") }
  if response.code == "200" && response.body.include?("Sign in to Trackline")
    puts "Trackline is already running: #{url}"
    open_browser(url)
    exit
  end
  abort "Port #{port} is in use by another app. Change PORT in config/local.cmd."
rescue Errno::ECONNREFUSED
  # No listener: prepare and start this app.
rescue Timeout::Error, IOError, SystemCallError => error
  abort "Unable to check port #{port}: #{error.message}"
end

unless system(RbConfig.ruby, "-S", "bundle", "check", out: File::NULL)
  abort "Dependency installation failed. Run bundle install and try again." unless system(RbConfig.ruby, "-S", "bundle", "install")
end

require_relative "../config/boot"
require_relative "../lib/trackline/database_backup"

database = ENV.fetch("TRACKLINE_DATABASE", File.join(root, "storage/development.sqlite3"))
if File.file?(database)
  backup = Trackline::DatabaseBackup.new(
    database: database,
    directory: ENV.fetch("TRACKLINE_BACKUP_DIR", File.join(root, "storage/backups"))
  ).create
  puts "Automatic backup: #{backup}"
end

abort "Database preparation failed. See the error above." unless system(RbConfig.ruby, "bin/rails", "db:prepare")
FileUtils.mkdir_p(File.join(root, "tmp/pids"))
puts "Trackline: #{url}"
puts "Keep this window open. Press Ctrl+C to stop Trackline."
STDOUT.flush

Thread.new do
  60.times do
    begin
      response = Net::HTTP.start("127.0.0.1", port, open_timeout: 1, read_timeout: 1) { |http| http.get("/up") }
      if response.code == "200"
        open_browser(url)
        break
      end
    rescue IOError, SystemCallError, Timeout::Error
      # Server is still booting.
    end
    sleep 1
  end
end

system(RbConfig.ruby, "bin/rails", "server", "-b", "127.0.0.1", "-p", port.to_s)
exit($?.exitstatus || 1)
