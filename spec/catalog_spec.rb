# frozen_string_literal: true

RSpec.describe Legion::Extensions::Detect do
  describe 'CATALOG' do
    let(:catalog) { described_class::CATALOG }

    it 'is a frozen array' do
      expect(catalog).to be_an(Array)
      expect(catalog).to be_frozen
    end

    it 'has required keys on every rule' do
      catalog.each do |rule|
        expect(rule).to have_key(:name), "rule missing :name — #{rule.inspect}"
        expect(rule).to have_key(:extensions), "rule missing :extensions — #{rule[:name]}"
        expect(rule).to have_key(:signals), "rule missing :signals — #{rule[:name]}"
        expect(rule[:extensions]).to be_an(Array)
        expect(rule[:signals]).to be_an(Array)
        expect(rule[:signals]).not_to be_empty, "rule #{rule[:name]} has no signals"
      end
    end

    it 'has no duplicate rule names' do
      names = catalog.map { |r| r[:name] }
      expect(names).to eq(names.uniq)
    end

    it 'uses only recognized signal types' do
      catalog.each do |rule|
        rule[:signals].each do |signal|
          expect(described_class::SIGNAL_TYPES).to include(signal[:type]),
                                                   "#{rule[:name]} has unknown signal type #{signal[:type]}"
        end
      end
    end

    it 'has a match value on every signal' do
      catalog.each do |rule|
        rule[:signals].each do |signal|
          expect(signal[:match]).not_to be_nil, "#{rule[:name]} has signal without :match"
        end
      end
    end

    it 'contains at least 15 rules' do
      expect(catalog.size).to be >= 15
    end
  end

  describe 'SIGNAL_TYPES' do
    it 'includes all expected types' do
      expect(described_class::SIGNAL_TYPES).to include(:app, :brew_formula, :brew_cask, :env, :port, :file)
    end
  end

  describe 'SCAN_PORTS' do
    it 'is a frozen array of integers' do
      expect(described_class::SCAN_PORTS).to be_an(Array)
      expect(described_class::SCAN_PORTS).to all(be_an(Integer))
    end
  end
end
