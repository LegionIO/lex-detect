# frozen_string_literal: true

RSpec.describe Legion::Extensions::Detect::Installer do
  describe '.install' do
    it 'installs gems successfully' do
      allow(Gem).to receive(:install).with('lex-slack')
      allow(Gem).to receive(:install).with('lex-todoist')

      result = described_class.install(%w[lex-slack lex-todoist])
      expect(result[:installed]).to eq(%w[lex-slack lex-todoist])
      expect(result[:failed]).to be_empty
    end

    it 'captures failed installs' do
      allow(Gem).to receive(:install).with('lex-slack').and_raise(StandardError, 'network error')

      result = described_class.install(['lex-slack'])
      expect(result[:installed]).to be_empty
      expect(result[:failed]).to eq([{ name: 'lex-slack', error: 'network error' }])
    end

    it 'returns list without installing in dry_run mode' do
      expect(Gem).not_to receive(:install)
      result = described_class.install(%w[lex-slack lex-todoist], dry_run: true)
      expect(result[:installed]).to eq(%w[lex-slack lex-todoist])
      expect(result[:failed]).to be_empty
    end

    it 'handles empty gem list' do
      result = described_class.install([])
      expect(result[:installed]).to be_empty
      expect(result[:failed]).to be_empty
    end

    it 'continues installing after a failure' do
      allow(Gem).to receive(:install).with('lex-slack').and_raise(StandardError, 'fail')
      allow(Gem).to receive(:install).with('lex-todoist')

      result = described_class.install(%w[lex-slack lex-todoist])
      expect(result[:installed]).to eq(['lex-todoist'])
      expect(result[:failed].size).to eq(1)
    end
  end
end
