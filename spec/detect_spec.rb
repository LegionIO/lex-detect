# frozen_string_literal: true

RSpec.describe Legion::Extensions::Detect do
  describe '.scan' do
    it 'delegates to Scanner.scan' do
      allow(described_class::Scanner).to receive(:scan).and_return([])
      expect(described_class.scan).to eq([])
      expect(described_class::Scanner).to have_received(:scan)
    end
  end

  describe '.missing' do
    it 'returns gem names that are not installed' do
      allow(described_class::Scanner).to receive(:scan).and_return([
                                                                     {
                                                                       name:       'Slack',
                                                                       extensions: ['lex-slack'],
                                                                       installed:  { 'lex-slack' => false }
                                                                     },
                                                                     {
                                                                       name:       'Redis',
                                                                       extensions: %w[lex-redis legion-cache],
                                                                       installed:  { 'lex-redis' => false, 'legion-cache' => true }
                                                                     }
                                                                   ])

      expect(described_class.missing).to eq(%w[lex-slack lex-redis])
    end

    it 'returns empty array when all extensions are installed' do
      allow(described_class::Scanner).to receive(:scan).and_return([
                                                                     {
                                                                       name:       'GitHub',
                                                                       extensions: ['lex-github'],
                                                                       installed:  { 'lex-github' => true }
                                                                     }
                                                                   ])

      expect(described_class.missing).to eq([])
    end

    it 'deduplicates gem names across rules' do
      allow(described_class::Scanner).to receive(:scan).and_return([
                                                                     {
                                                                       name:       'PostgreSQL',
                                                                       extensions: ['legion-data'],
                                                                       installed:  { 'legion-data' => false }
                                                                     },
                                                                     {
                                                                       name:       'MySQL',
                                                                       extensions: ['legion-data'],
                                                                       installed:  { 'legion-data' => false }
                                                                     }
                                                                   ])

      expect(described_class.missing).to eq(['legion-data'])
    end
  end

  describe '.install_missing!' do
    it 'installs missing gems' do
      allow(described_class).to receive(:missing).and_return(%w[lex-slack])
      allow(described_class::Installer).to receive(:install)
        .with(%w[lex-slack], dry_run: false)
        .and_return({ installed: %w[lex-slack], failed: [] })

      result = described_class.install_missing!
      expect(result[:installed]).to eq(%w[lex-slack])
    end

    it 'supports dry_run mode' do
      allow(described_class).to receive(:missing).and_return(%w[lex-slack])
      allow(described_class::Installer).to receive(:install)
        .with(%w[lex-slack], dry_run: true)
        .and_return({ installed: %w[lex-slack], failed: [] })

      result = described_class.install_missing!(dry_run: true)
      expect(result[:installed]).to eq(%w[lex-slack])
    end
  end

  describe '.catalog' do
    it 'returns the CATALOG constant' do
      expect(described_class.catalog).to eq(described_class::CATALOG)
    end
  end

  describe '.data_required?' do
    it 'returns false' do
      expect(described_class.data_required?).to be false
    end
  end

  describe '.remote_invocable?' do
    it 'returns false' do
      expect(described_class.remote_invocable?).to be false
    end
  end

  describe 'VERSION' do
    it 'is defined' do
      expect(described_class::VERSION).to match(/\d+\.\d+\.\d+/)
    end
  end
end
