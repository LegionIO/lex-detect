# lex-detect

Environment-aware extension discovery for [LegionIO](https://github.com/LegionIO).

Scans your local environment (macOS apps, Homebrew packages, environment variables, open ports, config files) and recommends which `lex-*` extensions to install.

## Installation

```bash
gem install lex-detect
```

## Usage

```ruby
require 'legion/extensions/detect'

# Full scan — returns array of detection results
results = Legion::Extensions::Detect.scan
# => [{ name: 'Claude', extensions: ['lex-claude'],
#        matched_signals: ['app:Claude.app'], installed: { 'lex-claude' => true } }, ...]

# Just the missing gems
missing = Legion::Extensions::Detect.missing
# => ['lex-slack', 'lex-todoist']

# Install all missing
Legion::Extensions::Detect.install_missing!
# => { installed: ['lex-slack', 'lex-todoist'], failed: [] }

# Dry run
Legion::Extensions::Detect.install_missing!(dry_run: true)

# View the catalog
Legion::Extensions::Detect.catalog
```

## Detection Catalog

| Name | Extensions | Signal Types |
|------|-----------|-------------|
| Claude | lex-claude | app, brew_cask, env |
| OpenAI | lex-openai | app, brew_cask, env |
| Ollama | lex-openai | brew_formula, port |
| Slack | lex-slack | app, brew_cask |
| Microsoft Teams | lex-microsoft_teams | app, brew_cask |
| Todoist | lex-todoist | app, brew_cask |
| GitHub | lex-github | app, brew_formula, brew_cask, env |
| Consul | lex-consul | brew_formula, port |
| Vault | lex-vault | brew_formula, port, env |
| Nomad | lex-nomad | brew_formula, port |
| Terraform | lex-tfe | brew_formula, file |
| RabbitMQ | legion-transport | brew_formula, port, env |
| Redis | lex-redis, legion-cache | brew_formula, port, env |
| Memcached | legion-cache | brew_formula, port |
| PostgreSQL | legion-data | brew_formula, port, env |
| MySQL | legion-data | brew_formula, port |
| Chef | lex-chef | app, file |
| S3 / AWS | lex-s3 | brew_formula, env, file |
| Elasticsearch | lex-elasticsearch | brew_formula, port |
| InfluxDB | lex-influxdb | brew_formula, port |

## License

MIT
