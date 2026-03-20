# Changelog

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
