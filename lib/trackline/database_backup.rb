require "sqlite3"
require "fileutils"
require "securerandom"

module Trackline
  class DatabaseBackup
    TABLES = %w[users sessions companies job_applications notes stage_changes schema_migrations].freeze

    def initialize(database:, directory:)
      @database = File.expand_path(database)
      @directory = File.expand_path(directory)
    end

    def create
      raise "Database does not exist yet. Start Trackline first." unless File.file?(@database)

      FileUtils.mkdir_p(@directory)
      path = File.join(@directory, "trackline-#{Time.now.utc.strftime('%Y%m%d-%H%M%S')}-#{SecureRandom.hex(4)}.sqlite3")
      copy(@database, path)
      validate!(path)
      path
    end

    def restore(snapshot:)
      snapshot = File.expand_path(snapshot)
      raise "Choose a backup file, not the active database." if snapshot == @database
      validate!(snapshot)
      safety_backup = create if File.file?(@database)
      copy(snapshot, @database)
      SQLite3::Database.new(@database) { |db| db.execute("DELETE FROM sessions") }
      safety_backup
    end

    private

    def validate!(path)
      raise "Backup file does not exist." unless File.file?(path)

      SQLite3::Database.new(path, readonly: true) do |db|
        raise "Backup failed SQLite integrity validation." unless db.get_first_value("PRAGMA integrity_check") == "ok"
        names = db.execute("SELECT name FROM sqlite_master WHERE type = 'table'").flatten
        raise "This is not a Trackline backup." unless (TABLES - names).empty?
        raise "Backup contains broken relationships." unless db.execute("PRAGMA foreign_key_check").empty?
      end
    end

    def copy(source_path, destination_path)
      FileUtils.mkdir_p(File.dirname(destination_path))
      SQLite3::Database.new(source_path, readonly: true) do |source|
        SQLite3::Database.new(destination_path) do |destination|
          source.busy_timeout = destination.busy_timeout = 5_000
          backup = SQLite3::Backup.new(destination, "main", source, "main")
          begin
            result = backup.step(-1)
            raise "Database is busy; close Trackline and try again (SQLite #{result})." unless result == SQLite3::Constants::ErrorCode::DONE
          ensure
            backup.finish
          end
        end
      end
    end
  end
end
