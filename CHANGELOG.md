# Changelog

## [0.2.2] - 2026-03-22

### Changed
- Added runtime dependencies to gemspec: legion-cache >= 1.3.11, legion-crypt >= 1.4.9, legion-data >= 1.4.17, legion-json >= 1.2.1, legion-logging >= 1.3.2, legion-settings >= 1.3.14, legion-transport >= 1.3.9
- Updated spec_helper to require real sub-gem helpers and stub Legion::Extensions::Helpers::Lex, Actors::Once, and Actors::Every for isolated test loading
- Fixed CancelTask spec to properly simulate Legion::Data unavailability by temporarily removing the constant

## [0.2.1] - 2026-03-22

### Added
- `Formatters::Json` passthrough formatter returning detections unchanged (or as pretty-printed JSON via `.to_json`)
- `Formatters` module entry point with `Formatters.format(detections, format:)` dispatcher for `:sarif`, `:markdown`, and `:json`
- `format_results` now delegates to `Formatters.format` instead of dispatching inline
- 5 new specs for `Formatters::Json` covering passthrough identity, field preservation, JSON serialization, and empty input

## [0.2.0] - 2026-03-22

### Added
- SARIF 2.1.0 formatter (`Formatters::Sarif`) for GitHub Code Scanning integration
- Markdown PR comment formatter (`Formatters::MarkdownPr`) for GitHub PR annotations
- `format_results(format:, detections:)` public API method supporting `:sarif`, `:markdown`, and `:json` output formats

## [0.1.7] - 2026-03-22

### Fixed
- `TaskObserver` queries now use `created` column instead of nonexistent `started_at` on the tasks table, fixing `PG::UndefinedColumn` errors on PostgreSQL

## [0.1.6] - 2026-03-20

### Fixed
- `FullScan`, `DeltaScan`, and `ObserverTick` actors now override `runner_class` to return `self.class`, preventing the framework from attempting `Kernel.const_get` lookups for non-existent constants like `Runners::FullScan`

## [0.1.5] - 2026-03-20

### Fixed
- Actor module namespace corrected from `Actors` (plural) to `Actor` (singular) to match framework expectations; resolves "Actor constant not defined, skipping" warnings for FullScan, DeltaScan, and ObserverTick

## [0.1.4] - 2026-03-20

### Changed
- Version bump for deployment (0.1.3 was released before task observer and cancel task changes landed)

## [0.1.3] - 2026-03-20

### Added
- `Runners::TaskObserver` for monitoring task failure patterns; supports DB-based `observe(since:)` and array-based `observe(tasks:)` calling styles
- `check_timeout_risk` detects tasks running beyond 2x expected duration and emits `timeout_risk` alert
- `check_repeated_failure` detects >=3 failures in 10 minutes per runner class
- `publish_alerts` forwards structured alerts to AMQP when `Legion::Transport` is available
- `record_observations` persists per-task observation records to `Legion::Data::Local` observer_events table
- `check_and_publish_failure_patterns` publishes failure pattern events to AMQP for self-healing pipeline integration
- `extract_gem_name` helper derives gem name from runner class string
- `build_failure_pattern` creates structured failure pattern hash
- `Runners::CancelTask` sets `cancelled_at` timestamp on tasks, guarded by `Legion::Data` availability
- `Actors::ObserverTick` runs `TaskObserver#observe` every 60 seconds, passing `since:` for incremental DB scans
- Local migration `20260320000001_create_observer_events` creates observer_events table for cognitive observation history

## [0.1.2] - 2026-03-19

### Added
- `FullScan` Once actor: runs full environment scan at boot with 2s delay, persists results and writes traces
- `DeltaScan` Every actor: runs delta detection every 300s, computes additions/removals via Set comparison
- Data::Local migration for detect_results table (optional persistence)

## [0.1.1] - 2026-03-18

### Changed
- Switch CI to reusable workflows from LegionIO/.github

## [0.1.0] - 2026-03-18

### Added
- Detection catalog with 20 rules covering AI providers, communication, productivity, developer tools, HashiCorp, infrastructure, and operations
- Scanner module: probes macOS apps, Homebrew formulas/casks, environment variables, TCP ports, and config files
- Installer module: `Gem.install` wrapper with dry_run support
- Public API: `scan`, `missing`, `install_missing!`, `catalog`
- Parallel port scanning with 1-second connect timeout
- Zero runtime dependencies
