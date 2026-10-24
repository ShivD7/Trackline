# Using Trackline

Trackline is ready for a personal job search on one computer. It runs a Rails server locally and stores data in SQLite. It does not require a paid service, an AI key, Redis, or a separate background worker.

## Start on Windows

1. Install Ruby **3.4.11 with Devkit** using RubyInstaller if Ruby is not already installed. Include Ruby in PATH and complete the MSYS2 development-tool installation (`ridk install 3`).
2. Double-click **Start Trackline.cmd** in the project folder.
3. The launcher checks dependencies, backs up an existing database, prepares migrations without replacing data, and opens `http://127.0.0.1:3001`.
4. Create an account, then add your own companies and applications. Each account has its own workspace.

Keep the launcher window open while using the app. Press **Ctrl+C** in that window to stop it. A second launch opens the existing Trackline instance. If another program uses the port, copy `config/local.cmd.example` to `config/local.cmd`, set a different `PORT`, and restart.

From a terminal, the equivalent command is `ruby script/start.rb`. On non-Windows systems, open the printed URL yourself.

The launcher binds to `127.0.0.1`, so the local development server is accessible only from this computer. A GitHub push does not deploy the app or upload your local data.

## Daily use

Add an application with a company name and role title. Choose a stage, record the date when applied, and optionally set a follow-up date. Existing company names are suggested only from your own account. Search and filter from Applications, view stage totals on Overview, and use Pipeline for a board view. Add dated notes after conversations and mark follow-ups complete when finished.

Follow-up dates are displayed in the app; automatic email reminders are not part of this release. The configured time zone is Eastern Time.

## Recover a forgotten password

In the default local setup, no email provider is needed:

1. Choose **Forgot password?** and enter the email address used for your account.
2. Double-click **Open Reset Emails.cmd** in the project folder.
3. Open the latest matching `.txt` message in Notepad and copy its complete reset URL into your browser.
4. Choose a password of at least eight characters. Reset links expire after 15 minutes and stop working after a successful reset. All previous sessions are signed out.

These messages are private files under `tmp/mail`, not a public web page. Anyone with access to your Windows files can read them, so keep your Windows account protected. You can delete expired messages.

### Optional real email

Copy `config/local.cmd.example` to `config/local.cmd` and enter your provider's `SMTP_ADDRESS`, `SMTP_PORT` (usually 587), `SMTP_USERNAME`, `SMTP_PASSWORD`, and verified `TRACKLINE_MAIL_FROM`. Restart using the launcher. Use an app-specific password if your provider requires one. In Windows command files, a literal `%` in a value must be written as `%%`.

Reset emails are sent during the request, so they do not need a job worker. Delivery errors show a retry message rather than silently claiming success. Real delivery still requires valid credentials from your mail provider. The local settings file is excluded from Git and Docker builds. Never commit credentials.

## Back up and restore

The default database is `storage/development.sqlite3`. Every fresh launcher start creates a timestamped snapshot under `storage/backups` before preparing the database. **Backup Trackline.cmd** creates another snapshot on demand, even while the app is running. The backup uses SQLite's snapshot API to include committed journal data, rather than simply copying an open database file.

Keep a copy of backups outside this computer, or set `TRACKLINE_BACKUP_DIR` in `config/local.cmd` to a second drive. There is no automatic deletion of older backups. Backups include all accounts, password hashes, applications, notes, and stage history; store them privately. They are excluded from Git.

To restore:

1. Stop Trackline with Ctrl+C. Do not restore while another copy is running.
2. Double-click **Restore Trackline.cmd**.
3. Paste a full backup filename from the displayed list and type `RESTORE`.
4. The helper validates SQLite integrity, Trackline tables, and relationships. It saves the current database as a safety snapshot before restoring the chosen backup.
5. Start Trackline again and sign in. Sessions are removed during restore; records added after the chosen snapshot remain available in the safety backup.

Terminal equivalents:

```powershell
ruby script/data.rb backup
ruby script/data.rb list
ruby script/data.rb restore "C:\full\path\trackline-backup.sqlite3" --confirm
```

The restore helper refuses to run while `tmp/pids/server.pid` exists. If a crash left that file behind, confirm the Rails server has stopped before removing that specific stale PID file.

## Existing records from the old version

Signup never automatically takes ownership of older records. If your previous data had no account owner, first create your account, stop the server, then run:

```powershell
$env:EMAIL = "your-account@example.com"
ruby bin/rails accounts:claim_legacy
Remove-Item Env:EMAIL
```

This local development task assigns only unowned companies and their associated applications, notes, and history to the named existing account. Other users' owned records are untouched.

## Setup and sample data

Normal database preparation is safe to repeat:

```powershell
bundle install
ruby bin/rails db:prepare
```

New installations start empty. Demo data requires an explicitly empty development database and `TRACKLINE_DEMO=1`; existing databases are never cleared by seeding. The optional demo login defaults to `demo@trackline.app` / `password123`, with overrides through `TRACKLINE_DEMO_EMAIL` and `TRACKLINE_DEMO_PASSWORD`. Do not use the sample account for private or public hosting.

## How it works

Trackline uses Rails 8.1, server-rendered ERB views, Turbo, Stimulus, and SQLite. User accounts own companies; applications belong to those companies, and notes/history belong to applications. Queries start from the signed-in user, including form suggestions and dashboard totals. This keeps ownership consistent without duplicate owner fields on every table.

Passwords are hashed with bcrypt. Signed HTTP-only cookies identify server-side sessions. Application creation and stage transitions use database transactions so records and their history are saved together. Recovery uses signed, expiring tokens; successful password resets revoke sessions.

SQLite is appropriate for this small, single-server application and supports persistent files and consistent snapshots. There is no need for separate API, database, cache, or queue services for personal use.

## Tests

```powershell
$env:RAILS_ENV = "test"
ruby bin/rails db:prepare
ruby bin/rails test
ruby bin/rails test:system
bundle exec rubocop
bundle exec brakeman --no-pager
Remove-Item Env:RAILS_ENV
```

Browser tests require Chrome (Selenium locates the matching driver). Tests use `storage/test.sqlite3`, separate from personal data. GitHub Actions runs the suite, browser workflow, style checker, and security scanner on pushes and pull requests.

## Hosting later

The repository includes production configuration but is not publicly hosted by these changes. Production requires:

- `RAILS_ENV=production`, a stable private `SECRET_KEY_BASE`, and the installed bundle.
- `TRACKLINE_URL=https://your-domain.example`, `SMTP_ADDRESS`, and a verified `TRACKLINE_MAIL_FROM` (plus your provider's other SMTP settings).
- `TRACKLINE_DATABASE` pointing to a persistent SQLite file; a container needs a mounted persistent storage directory.
- HTTPS termination, compiled assets, migrations, and private off-machine backups.

Production uses one application process with in-memory cache/cable adapters; no real-time or durable job features depend on them. Password resets are delivered synchronously. Multiple-server deployments would need a different database and shared cache design.

## Troubleshooting

- **Ruby is missing:** reopen the terminal after installing RubyInstaller and confirm `ruby -v` works.
- **bcrypt cannot compile:** complete `ridk install 3`, then run `bundle install`.
- **Port is occupied:** close the other app or change `PORT` in local settings. The launcher will not start a second server on the same port.
- **Reset message is missing:** confirm the exact registered email, request a new link, and check the newest local text file. With SMTP configured, check the provider credentials and spam folder.
- **Missing database or migrations:** use the launcher; never run `db:reset` against personal data.
- **Legacy applications seem missing:** use the explicit ownership task above after creating your account.
- **Backup fails:** check available disk space and folder permissions. Startup stops on backup failure to avoid applying migrations without a snapshot.
