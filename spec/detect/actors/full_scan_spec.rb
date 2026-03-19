# frozen_string_literal: true

require 'spec_helper'

unless defined?(Legion::Extensions::Actors::Once)
  module Legion
    module Extensions
      module Actors
        class Once
          def enabled? = true

          def delay = 1.0

          def use_runner? = false
        end
      end
    end
  end
end

require_relative '../../../lib/legion/extensions/detect/actors/full_scan'

RSpec.describe Legion::Extensions::Detect::Actors::FullScan do
  subject(:actor) { described_class.allocate }

  describe '#action' do
    it 'calls Scanner.scan and returns results' do
      allow(Legion::Extensions::Detect::Scanner).to receive(:scan).and_return([
                                                                                { name: 'Redis', extensions: ['lex-redis'], matched_signals: ['port:6379'],
installed: {} }
                                                                              ])

      results = actor.action
      expect(results).to be_an(Array)
      expect(results.first[:name]).to eq('Redis')
    end
  end
end
