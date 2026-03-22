# lex-detect: Environment-Aware Extension Discovery

**Repository Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-core/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Legion Extension that scans the local environment and recommends which `lex-*` extensions to install. Detects macOS apps, Homebrew formulas/casks, environment variables, open TCP ports, and config files, then maps them to recommended extensions via a declarative catalog.

**GitHub**: https://github.com/LegionIO/lex-detect
**License**: MIT
**Version**: 0.2.0

## Architecture

```
Legion::Extensions::Detect
├── CATALOG (constant)     # Frozen array of 20 detection rules
├── Scanner                # Probes environment, matches against catalog
├── Installer              # Gem.install wrapper with dry_run support
├── Actors/
│   ├── FullScan (Once)    # Full environment scan at startup
│   └── DeltaScan (Every)  # Periodic delta scan every 6 hours
└── Entry Point            # Public API: scan, missing, install_missing!, catalog
```

Local-only utility gem. Actors run scans but do not create AMQP queues.

- `data_required? false` — no database needed
- `remote_invocable? false` — no AMQP queue creation

## Signal Types

| Type | Source | Platform |
|------|--------|----------|
| `:app` | `/Applications/*.app` | macOS |
| `:brew_formula` | `brew list --formula` | macOS/Linux |
| `:brew_cask` | `brew list --cask` | macOS |
| `:env` | `ENV.keys` | all |
| `:port` | TCP connect probe (1s timeout) | all |
| `:file` | `File.exist?` with `~` expansion | all |

## Public API

```ruby
Legion::Extensions::Detect.scan             # full scan results
Legion::Extensions::Detect.missing          # uninstalled gem names
Legion::Extensions::Detect.install_missing! # install missing gems
Legion::Extensions::Detect.catalog          # raw CATALOG constant
```

## Design Docs

- Design: `docs/work/completed/2026-03-18-lex-detect-design.md`
- Implementation: `docs/work/completed/2026-03-18-lex-detect-implementation.md`

## Testing

54 specs across 9 spec files.

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

---

**Maintained By**: Matthew Iverson (@Esity)
