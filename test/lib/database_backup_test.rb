require "test_helper"
require "tmpdir"
require_relative "../../lib/trackline/database_backup"

class DatabaseBackupTest < ActiveSupport::TestCase
  setup do
    @directory = Dir.mktmpdir("trackline-backup-test")
    @path = File.join(@directory, "live.sqlite3")
    SQLite3::Database.new(@path) do |db|
      Trackline::DatabaseBackup::TABLES.each { |table| db.execute("CREATE TABLE #{table} (id INTEGER PRIMARY KEY, value TEXT)") }
      db.execute("PRAGMA journal_mode=WAL")
      db.execute("INSERT INTO companies(value) VALUES ('Original')")
    end
    @backups = Trackline::DatabaseBackup.new(database: @path, directory: File.join(@directory, "backups"))
  end

  teardown { FileUtils.remove_entry(@directory) }

  test "restores a complete snapshot and saves the previous database" do
    snapshot = @backups.create
    SQLite3::Database.new(@path) do |db|
      db.execute("UPDATE companies SET value = 'Changed'")
      db.execute("INSERT INTO sessions(value) VALUES ('Old login')")
    end

    safety = @backups.restore(snapshot: snapshot)

    SQLite3::Database.new(@path) do |db|
      assert_equal "Original", db.get_first_value("SELECT value FROM companies")
      assert_equal 0, db.get_first_value("SELECT count(*) FROM sessions")
    end
    SQLite3::Database.new(safety) { |db| assert_equal "Changed", db.get_first_value("SELECT value FROM companies") }
  end

  test "captures committed WAL data while another connection is open" do
    SQLite3::Database.new(@path) do |db|
      db.execute("INSERT INTO notes(value) VALUES ('Latest note')")
      snapshot = @backups.create
      SQLite3::Database.new(snapshot) { |copy| assert_equal "Latest note", copy.get_first_value("SELECT value FROM notes") }
    end
  end

  test "rejects invalid or unrelated databases before touching current data" do
    invalid = File.join(@directory, "invalid.sqlite3")
    File.write(invalid, "not a database")
    assert_raises(SQLite3::Exception) { @backups.restore(snapshot: invalid) }
    SQLite3::Database.new(@path) { |db| assert_equal "Original", db.get_first_value("SELECT value FROM companies") }
  end
end
