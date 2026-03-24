# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe Legion::Extensions::Detect::Formatters::Json do
  let(:detections) do
    [
      {
        name:            'Redis',
        extensions:      ['lex-redis'],
        matched_signals: ['brew_formula:redis'],
        installed:       { 'lex-redis' => false }
      },
      {
        name:            'Vault',
        extensions:      ['lex-vault'],
        matched_signals: ['port:8200'],
        installed:       { 'lex-vault' => true }
      }
    ]
  end

  describe '.format' do
    it 'returns the detections array unchanged' do
      expect(described_class.format(detections)).to equal(detections)
    end

    it 'preserves all detection fields' do
      result = described_class.format(detections)
      expect(result.first[:name]).to eq('Redis')
      expect(result.first[:extensions]).to eq(['lex-redis'])
      expect(result.first[:matched_signals]).to eq(['brew_formula:redis'])
      expect(result.first[:installed]).to eq({ 'lex-redis' => false })
    end
  end

  describe '.to_json' do
    it 'produces a valid JSON string' do
      json_str = described_class.to_json(detections)
      expect { JSON.parse(json_str) }.not_to raise_error
    end

    it 'round-trips the detection names' do
      json_str = described_class.to_json(detections)
      parsed = JSON.parse(json_str, symbolize_names: true)
      expect(parsed.map { |d| d[:name] }).to eq(%w[Redis Vault])
    end
  end

  describe '.format with empty input' do
    it 'returns an empty array' do
      expect(described_class.format([])).to eq([])
    end
  end
end
