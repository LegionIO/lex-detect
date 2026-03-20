# frozen_string_literal: true

require 'spec_helper'

unless defined?(Legion::Extensions::Actors::Every)
  module Legion
    module Extensions
      module Actors
        class Every
          def initialize(**_opts); end

          def enabled? = true

          def time = 300

          def run_now? = false

          def use_runner? = false
        end
      end
    end
  end
end

require_relative '../../../lib/legion/extensions/detect/actors/delta_scan'

RSpec.describe Legion::Extensions::Detect::Actor::DeltaScan do
  subject(:actor) { described_class.allocate }

  describe '#action' do
    it 'returns only changed results compared to last scan' do
      allow(Legion::Extensions::Detect::Scanner).to receive(:scan).and_return([
                                                                                { name: 'Redis', extensions: ['lex-redis'], matched_signals: ['port:6379'],
installed: {} }
                                                                              ])
      allow(actor).to receive(:last_scan_results).and_return([])

      results = actor.action
      expect(results).to be_a(Hash)
      expect(results[:added]).to be_an(Array)
    end
  end

  describe '#time' do
    it 'returns the configured interval' do
      expect(actor.time).to be_a(Integer)
    end
  end
end
