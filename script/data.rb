require_relative "../config/boot"
require_relative "../lib/trackline/database_backup"

abort "This helper manages the local development database only." unless ENV.fetch("RAILS_ENV", "development") == "development"
root = File.expand_path("..", __dir__)
Dir.chdir(root)
database = ENV.fetch("TRACKLINE_DATABASE", File.join(root, "storage/development.sqlite3"))
directory = ENV.fetch("TRACKLINE_BACKUP_DIR", File.join(root, "storage/backups"))
backups = Trackline::DatabaseBackup.new(database: database, directory: directory)

begin
  case ARGV.shift
  when "backup"
    puts "Backup saved: #{backups.create}"
  when "restore"
    path = ARGV.shift
    abort 'Usage: ruby script/data.rb restore "path/to/backup.sqlite3" --confirm' unless path && ARGV == [ "--confirm" ]
    abort "Stop Trackline before restoring. A server PID file is still present in tmp/pids." if File.exist?(File.join(root, "tmp/pids/server.pid"))
    safety_backup = backups.restore(snapshot: path)
    puts "Restored. Sign in again after starting Trackline."
    puts "Previous database saved: #{safety_backup}" if safety_backup
  when "list"
    puts Dir.glob(File.join(directory, "trackline-*.sqlite3")).sort.reverse
  else
    abort "Usage: ruby script/data.rb backup | list | restore BACKUP --confirm"
  end
rescue SQLite3::Exception, RuntimeError => error
  abort "Unable to complete data operation: #{error.message}"
end
