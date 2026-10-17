# Trackline

Trackline is a focused job-application tracker built with Ruby on Rails. It keeps roles, companies, notes, follow-up dates, contacts, and stage history in one calm dashboard—without an external account or service.

## What it does

- Tracks opportunities from wishlist through offer, rejection, or withdrawal
- Searches and filters by company, role, location, stage, priority, and work mode
- Surfaces overdue and upcoming follow-ups on the dashboard
- Records a permanent stage-change timeline
- Stores dated notes for recruiter calls and interviews
- Groups applications by company
- Ships with realistic demo data and an automated test suite
- Adapts to desktop and mobile layouts

## Architecture

Trackline is a conventional Rails monolith. That choice is deliberate: this domain is a cohesive CRUD workflow, so splitting it into services would add deployment and data-consistency costs without creating useful boundaries.

```text
Browser
  │  HTML forms + Turbo navigation
  ▼
Rails routes
  ├── DashboardController        read model / summary queries
  ├── JobApplicationsController application workflow
  ├── CompaniesController       company CRUD
  └── NotesController           nested journal entries
        │
        ├── ApplicationStatusUpdater (transactional domain service)
        ▼
Active Record models
  Company ──< JobApplication ──< Note
                         └──────< StageChange
        │
        ▼
SQLite database
```

### Why these boundaries?

- **Server-rendered Rails + Hotwire:** most interactions are forms and navigation. Turbo makes them feel immediate while preserving accessible HTML and avoiding a separate JavaScript API/client.
- **SQLite:** a personal tracker has modest write concurrency. SQLite makes setup and backups trivial, while Active Record keeps a future PostgreSQL move straightforward.
- **Company as a separate model:** one organization can have several roles, and company research should not be duplicated on every application.
- **StageChange as an append-only record:** the current `status` makes filtering fast; the history table explains how an application got there.
- **ApplicationStatusUpdater service:** changing status and recording its history must be one transaction. Keeping that rule outside the controller makes it independently testable.
- **No authentication in this version:** the app is intentionally a local, single-user portfolio project. Before public deployment, authentication and per-user ownership should be added together.

## How a request works

When you submit an application form, Rails routes the request to `JobApplicationsController`. The controller resolves or creates the company, the model validates the data, and Active Record writes it to SQLite. On later edits, `ApplicationStatusUpdater` wraps the application update and stage-history insert in one database transaction. Rails renders HTML views; Turbo accelerates navigation and form responses without duplicating business logic in JavaScript.

## Requirements

- Ruby 3.4.x
- Ruby on Rails 8.1.x
- RubyInstaller with Devkit on Windows, or standard compiler tools on macOS/Linux

Node.js is not required. JavaScript dependencies are delivered through Rails Importmap.

## Run locally

### Windows

1. Install **Ruby+Devkit 3.4 (x64)** from [RubyInstaller](https://rubyinstaller.org/downloads/).
2. When the installer finishes, run the MSYS2 setup it offers and choose the default components.
3. Open PowerShell in this project folder and run:

```powershell
gem install bundler
bundle install
bin\rails db:prepare
bin\rails db:seed
bin\rails server
```

Open <http://localhost:3000>.

### macOS or Linux

Install Ruby 3.4 with your preferred version manager, then run:

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

## Verification

```powershell
bin\rails test
bin\rubocop
bin\brakeman --no-pager --no-threads
```

`--no-threads` avoids a Windows `Process.fork` limitation; it does not reduce the checks Brakeman performs. `db:seed` resets and recreates demonstration records. Do not run it against data you want to keep.

## Main folders

```text
app/controllers/  Request handling and orchestration
app/models/       Domain rules, associations, queries
app/services/     Transactional workflow objects
app/views/        Server-rendered interface
db/migrate/       Versioned database structure
db/seeds.rb       Repeatable demo dataset
test/             Model, service, and request tests
```

## Honest commit strategy

A portfolio repository is strongest when its history reflects real milestones. A clean sequence for this project is:

1. `Initialize Rails application`
2. `Model companies and job applications`
3. `Add dashboard and pipeline filters`
4. `Track notes and application stage history`
5. `Polish responsive interface`
6. `Add demo data and automated tests`
7. `Document architecture and local setup`

Create these commits as the corresponding work is completed, using their real timestamps. If much of the code was built in one session, use one honest initial commit and describe later improvements in release notes or a changelog; do not backdate commits.
