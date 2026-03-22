# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe Legion::Extensions::Detect::Formatters::Sarif do
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
        matched_signals: ['port:8200', 'env:VAULT_ADDR'],
        installed:       { 'lex-vault' => false }
      },
      {
        name:            'Redis',
        extensions:      %w[lex-redis legion-cache],
        matched_signals: ['brew_formula:redis'],
        installed:       { 'lex-redis' => false, 'legion-cache' => true }
      }
    ]
  end

  describe '.format' do
    subject(:sarif) { described_class.format(detections) }

    it 'produces valid SARIF 2.1.0 structure' do
      expect(sarif['$schema']).to eq('https://json.schemastore.org/sarif-2.1.0.json')
      expect(sarif['version']).to eq('2.1.0')
      expect(sarif['runs']).to be_an(Array)
      expect(sarif['runs'].size).to eq(1)
    end

    it 'includes tool driver info' do
      driver = sarif['runs'][0]['tool']['driver']
      expect(driver['name']).to eq('legion-detect')
      expect(driver['version']).to eq(Legion::Extensions::Detect::VERSION)
    end

    it 'generates rules for all extensions' do
      rules = sarif['runs'][0]['tool']['driver']['rules']
      rule_ids = rules.map { |r| r['id'] }
      expect(rule_ids).to include('detect/lex-claude', 'detect/lex-vault', 'detect/lex-redis', 'detect/legion-cache')
    end

    it 'only generates results for missing extensions' do
      results = sarif['runs'][0]['results']
      result_rules = results.map { |r| r['ruleId'] }
      expect(result_rules).to include('detect/lex-vault', 'detect/lex-redis')
      expect(result_rules).not_to include('detect/lex-claude', 'detect/legion-cache')
    end

    it 'includes matched signals in result properties' do
      results = sarif['runs'][0]['results']
      vault_result = results.find { |r| r['ruleId'] == 'detect/lex-vault' }
      expect(vault_result['properties']['matched_signals']).to eq(['port:8200', 'env:VAULT_ADDR'])
    end

    it 'sets level to warning for missing extensions' do
      results = sarif['runs'][0]['results']
      results.each do |r|
        expect(r['level']).to eq('warning')
      end
    end
  end

  describe '.to_json' do
    it 'produces valid JSON string' do
      json_str = described_class.to_json(detections)
      parsed = JSON.parse(json_str)
      expect(parsed['version']).to eq('2.1.0')
    end
  end

  describe '.format with no detections' do
    it 'returns empty results' do
      sarif = described_class.format([])
      expect(sarif['runs'][0]['results']).to eq([])
      expect(sarif['runs'][0]['tool']['driver']['rules']).to eq([])
    end
  end

  describe '.format when all extensions installed' do
    it 'returns empty results' do
      all_installed = [{
        name: 'Claude', extensions: ['lex-claude'],
        matched_signals: ['app:Claude.app'], installed: { 'lex-claude' => true }
      }]
      sarif = described_class.format(all_installed)
      expect(sarif['runs'][0]['results']).to eq([])
    end
  end
end
