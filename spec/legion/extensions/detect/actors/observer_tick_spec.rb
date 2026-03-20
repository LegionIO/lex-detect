# frozen_string_literal: true

module Legion
  module Extensions
    module Actors
      unless defined?(Every)
        class Every # rubocop:disable Lint/EmptyClass
        end
      end
    end

    module Detect
      module Runners
        module TaskObserver
          def observe(**_opts)
            { alerts: [], observed: 0 }
          end
        end
      end
    end
  end
end

$LOADED_FEATURES << 'legion/extensions/actors/every'

require_relative '../../../../../lib/legion/extensions/detect/actors/observer_tick'

RSpec.describe Legion::Extensions::Detect::Actor::ObserverTick do
  subject(:actor) { described_class.new }

  describe '#time' do
    it 'returns 60 seconds' do
      expect(actor.time).to eq(60)
    end
  end

  describe '#run_now?' do
    it 'returns false' do
      expect(actor.run_now?).to be false
    end
  end

  describe '#use_runner?' do
    it 'returns false' do
      expect(actor.use_runner?).to be false
    end
  end

  describe '#action' do
    it 'returns a hash with alerts key' do
      result = actor.action
      expect(result).to be_a(Hash)
      expect(result).to have_key(:alerts)
    end
  end
end
