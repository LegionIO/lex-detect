# frozen_string_literal: true

module Legion
  module Extensions
    module Detect
      CATALOG = [
        # AI Providers
        {
          name:       'Claude',
          extensions: ['lex-claude'],
          signals:    [
            { type: :app, match: 'Claude.app' },
            { type: :brew_cask, match: 'claude' },
            { type: :brew_cask, match: 'claude-code' },
            { type: :brew_formula, match: 'claude-code' },
            { type: :env, match: 'ANTHROPIC_API_KEY' }
          ]
        },
        {
          name:       'OpenAI',
          extensions: ['lex-openai'],
          signals:    [
            { type: :app, match: 'ChatGPT.app' },
            { type: :brew_cask, match: 'chatgpt' },
            { type: :brew_cask, match: 'codex' },
            { type: :env, match: 'OPENAI_API_KEY' }
          ]
        },
        {
          name:       'Ollama',
          extensions: ['lex-openai'],
          signals:    [
            { type: :brew_formula, match: 'ollama' },
            { type: :port, match: 11_434 }
          ]
        },

        # Communication
        {
          name:       'Slack',
          extensions: ['lex-slack'],
          signals:    [
            { type: :app, match: 'Slack.app' },
            { type: :brew_cask, match: 'slack' }
          ]
        },
        {
          name:       'Microsoft Teams',
          extensions: ['lex-microsoft_teams'],
          signals:    [
            { type: :app, match: 'Microsoft Teams.app' },
            { type: :brew_cask, match: 'microsoft-teams' }
          ]
        },

        # Productivity
        {
          name:       'Todoist',
          extensions: ['lex-todoist'],
          signals:    [
            { type: :app, match: 'Todoist.app' },
            { type: :brew_cask, match: 'todoist' },
            { type: :brew_cask, match: 'todoist-app' }
          ]
        },

        # Developer Tools
        {
          name:       'GitHub',
          extensions: ['lex-github'],
          signals:    [
            { type: :app, match: 'GitHub Desktop.app' },
            { type: :brew_formula, match: 'gh' },
            { type: :brew_cask, match: 'github' },
            { type: :env, match: 'GITHUB_TOKEN' }
          ]
        },

        # HashiCorp
        {
          name:       'Consul',
          extensions: ['lex-consul'],
          signals:    [
            { type: :brew_formula, match: /^consul/ },
            { type: :port, match: 8500 }
          ]
        },
        {
          name:       'Vault',
          extensions: ['lex-vault'],
          signals:    [
            { type: :brew_formula, match: /^vault/ },
            { type: :port, match: 8200 },
            { type: :env, match: 'VAULT_ADDR' }
          ]
        },
        {
          name:       'Nomad',
          extensions: ['lex-nomad'],
          signals:    [
            { type: :brew_formula, match: /^nomad/ },
            { type: :port, match: 4646 }
          ]
        },
        {
          name:       'Terraform',
          extensions: ['lex-tfe'],
          signals:    [
            { type: :brew_formula, match: 'terraform' },
            { type: :brew_formula, match: 'tfenv' },
            { type: :file, match: '~/.terraform.d/credentials.tfrc.json' }
          ]
        },

        # Infrastructure
        {
          name:       'RabbitMQ',
          extensions: ['legion-transport'],
          signals:    [
            { type: :brew_formula, match: 'rabbitmq' },
            { type: :port, match: 5672 },
            { type: :env, match: 'AMQP_URL' }
          ]
        },
        {
          name:       'Redis',
          extensions: %w[lex-redis legion-cache],
          signals:    [
            { type: :brew_formula, match: 'redis' },
            { type: :port, match: 6379 },
            { type: :env, match: 'REDIS_URL' }
          ]
        },
        {
          name:       'Memcached',
          extensions: ['legion-cache'],
          signals:    [
            { type: :brew_formula, match: 'memcached' },
            { type: :port, match: 11_211 }
          ]
        },
        {
          name:       'PostgreSQL',
          extensions: ['legion-data'],
          signals:    [
            { type: :brew_formula, match: /^postgresql/ },
            { type: :port, match: 5432 },
            { type: :env, match: 'DATABASE_URL' }
          ]
        },
        {
          name:       'MySQL',
          extensions: ['legion-data'],
          signals:    [
            { type: :brew_formula, match: /^mysql/ },
            { type: :port, match: 3306 }
          ]
        },

        # Operations
        {
          name:       'Chef',
          extensions: ['lex-chef'],
          signals:    [
            { type: :app, match: 'Chef Workstation App.app' },
            { type: :file, match: '~/.chef/config.rb' },
            { type: :file, match: '~/.chef/credentials' }
          ]
        },
        {
          name:       'S3 / AWS',
          extensions: ['lex-s3'],
          signals:    [
            { type: :brew_formula, match: 'awscli' },
            { type: :env, match: 'AWS_ACCESS_KEY_ID' },
            { type: :file, match: '~/.aws/credentials' }
          ]
        },
        {
          name:       'Elasticsearch',
          extensions: ['lex-elasticsearch'],
          signals:    [
            { type: :brew_formula, match: 'elasticsearch' },
            { type: :brew_formula, match: 'opensearch' },
            { type: :port, match: 9200 }
          ]
        },
        {
          name:       'InfluxDB',
          extensions: ['lex-influxdb'],
          signals:    [
            { type: :brew_formula, match: 'influxdb' },
            { type: :port, match: 8086 }
          ]
        }
      ].freeze

      SIGNAL_TYPES = %i[app brew_formula brew_cask env port file].freeze

      SCAN_PORTS = [5672, 6379, 11_211, 8200, 5432, 3306, 8500, 4646, 9200, 8086, 11_434].freeze
    end
  end
end
