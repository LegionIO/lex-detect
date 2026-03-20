# Changelog

## [0.1.3] - 2026-03-20

### Added
- `Runners::TaskObserver` for monitoring task failure patterns
- `check_and_publish_failure_patterns` publishes failure pattern events to AMQP for self-healing pipeline integration
- `extract_gem_name` helper derives gem name from runner class string
- `build_failure_pattern` creates structured failure pattern hash

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
