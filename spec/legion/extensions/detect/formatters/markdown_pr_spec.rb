# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Detect::Formatters::MarkdownPr do
  let(:detections) do
    [
      {
        name:            'Claude',
        extensions:      ['lex-claude'],
        matched_signals: ['app:Claude.app'],
        installed:       { 'lex-claude' => true }
      },
      {
        name:            'Vault',
        extensions:      ['lex-vault'],
        matched_signals: ['port:8200'],
        installed:       { 'lex-vault' => false }
      }
    ]
  end

  describe '.format' do
    subject(:output) { described_class.format(detections) }

    it 'includes the header' do
      expect(output).to include('## Legion Detect Findings')
    end

    it 'lists missing extensions with install command' do
      expect(output).to include('**Vault**')
      expect(output).to include('`lex-vault` not installed')
      expect(output).to include('gem install lex-vault')
    end

    it 'lists installed extensions with checkmark' do
      expect(output).to include('Claude')
      expect(output).to include('`lex-claude`')
      expect(output).to include(':white_check_mark:')
    end

    it 'includes version footer' do
      expect(output).to include("legion-detect v#{Legion::Extensions::Detect::VERSION}")
    end
  end

  describe '.format with no detections' do
    it 'indicates no extensions detected' do
      output = described_class.format([])
      expect(output).to include('No extensions detected')
    end
  end

  describe '.format with all installed' do
    it 'has no missing section' do
      all_installed = [{
        name: 'Claude', extensions: ['lex-claude'],
        matched_signals: ['app:Claude.app'], installed: { 'lex-claude' => true }
      }]
      output = described_class.format(all_installed)
      expect(output).not_to include('Missing Extensions')
      expect(output).to include('Installed (1)')
    end
  end
end
