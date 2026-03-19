# Changelog

## [0.1.0] - 2026-03-18

### Added
- Detection catalog with 20 rules covering AI providers, communication, productivity, developer tools, HashiCorp, infrastructure, and operations
- Scanner module: probes macOS apps, Homebrew formulas/casks, environment variables, TCP ports, and config files
- Installer module: `Gem.install` wrapper with dry_run support
- Public API: `scan`, `missing`, `install_missing!`, `catalog`
- Parallel port scanning with 1-second connect timeout
- Zero runtime dependencies
