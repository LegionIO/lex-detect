# frozen_string_literal: true

RSpec.describe Legion::Extensions::Detect::Scanner do
  let(:empty_env) do
    {
      apps:          [],
      brew_formulas: [],
      brew_casks:    [],
      env_vars:      [],
      ports:         [],
      files:         nil
    }
  end

  before do
    allow(described_class).to receive(:gather_environment).and_return(empty_env)
    allow(File).to receive(:exist?).and_return(false)
  end

  describe '.scan' do
    it 'returns an empty array when no signals match' do
      expect(described_class.scan).to eq([])
    end

    it 'detects an app signal' do
      empty_env[:apps] = ['Claude.app']
      results = described_class.scan
      expect(results.size).to be >= 1
      claude = results.find { |r| r[:name] == 'Claude' }
      expect(claude).not_to be_nil
      expect(claude[:extensions]).to eq(['lex-claude'])
      expect(claude[:matched_signals]).to include('app:Claude.app')
    end

    it 'detects a brew_formula signal with exact match' do
      empty_env[:brew_formulas] = ['gh']
      results = described_class.scan
      github = results.find { |r| r[:name] == 'GitHub' }
      expect(github).not_to be_nil
      expect(github[:matched_signals]).to include('brew_formula:gh')
    end

    it 'detects a brew_formula signal with regexp match' do
      empty_env[:brew_formulas] = ['consul-enterprise']
      results = described_class.scan
      consul = results.find { |r| r[:name] == 'Consul' }
      expect(consul).not_to be_nil
    end

    it 'detects a brew_cask signal' do
      empty_env[:brew_casks] = ['slack']
      results = described_class.scan
      slack = results.find { |r| r[:name] == 'Slack' }
      expect(slack).not_to be_nil
      expect(slack[:matched_signals]).to include('brew_cask:slack')
    end

    it 'detects an env var signal' do
      empty_env[:env_vars] = ['VAULT_ADDR']
      results = described_class.scan
      vault = results.find { |r| r[:name] == 'Vault' }
      expect(vault).not_to be_nil
      expect(vault[:matched_signals]).to include('env:VAULT_ADDR')
    end

    it 'detects a port signal' do
      empty_env[:ports] = [5672]
      results = described_class.scan
      rabbitmq = results.find { |r| r[:name] == 'RabbitMQ' }
      expect(rabbitmq).not_to be_nil
      expect(rabbitmq[:matched_signals]).to include('port:5672')
    end

    it 'detects a file signal' do
      allow(File).to receive(:exist?).with(File.expand_path('~/.chef/config.rb')).and_return(true)

      results = described_class.scan
      chef = results.find { |r| r[:name] == 'Chef' }
      expect(chef).not_to be_nil
      expect(chef[:matched_signals]).to include('file:~/.chef/config.rb')
    end

    it 'collects multiple matched signals for the same rule' do
      empty_env[:apps] = ['Claude.app']
      empty_env[:env_vars] = ['ANTHROPIC_API_KEY']
      results = described_class.scan
      claude = results.find { |r| r[:name] == 'Claude' }
      expect(claude[:matched_signals].size).to be >= 2
    end

    it 'includes installed status for each extension' do
      empty_env[:brew_formulas] = ['redis']
      allow(described_class).to receive(:gem_installed?).and_return(false)
      allow(described_class).to receive(:gem_installed?).with('legion-cache').and_return(true)

      results = described_class.scan
      redis = results.find { |r| r[:name] == 'Redis' }
      expect(redis[:installed]).to eq({ 'lex-redis' => false, 'legion-cache' => true })
    end

    it 'does not duplicate detections for the same rule' do
      empty_env[:apps] = ['Claude.app']
      empty_env[:brew_casks] = ['claude']
      results = described_class.scan
      claude_results = results.select { |r| r[:name] == 'Claude' }
      expect(claude_results.size).to eq(1)
    end
  end

  describe '.gather_environment' do
    before { allow(described_class).to receive(:gather_environment).and_call_original }

    it 'returns a hash with expected keys' do
      allow(described_class).to receive(:scan_applications).and_return([])
      allow(described_class).to receive(:scan_brew_formulas).and_return([])
      allow(described_class).to receive(:scan_brew_casks).and_return([])
      allow(described_class).to receive(:scan_ports).and_return([])

      env = described_class.gather_environment
      expect(env).to have_key(:apps)
      expect(env).to have_key(:brew_formulas)
      expect(env).to have_key(:brew_casks)
      expect(env).to have_key(:env_vars)
      expect(env).to have_key(:ports)
    end

    it 'includes actual ENV keys' do
      allow(described_class).to receive(:scan_applications).and_return([])
      allow(described_class).to receive(:scan_brew_formulas).and_return([])
      allow(described_class).to receive(:scan_brew_casks).and_return([])
      allow(described_class).to receive(:scan_ports).and_return([])

      env = described_class.gather_environment
      expect(env[:env_vars]).to include('PATH')
    end
  end

  describe '.reset!' do
    it 'clears the memoized environment' do
      described_class.instance_variable_set(:@gather_environment, { cached: true })
      described_class.reset!
      expect(described_class.instance_variable_get(:@gather_environment)).to be_nil
    end
  end
end
