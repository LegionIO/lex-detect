# frozen_string_literal: true

# This spec verifies that legion/extensions/detect can be required safely
# in an environment where Legion::Extensions::Actors is NOT defined.
# The actors should be skipped (not loaded) and the public API must still work.
RSpec.describe 'Legion::Extensions::Detect without Actors' do
  before(:all) do
    # spec_helper defines Actors before requiring detect, so we temporarily
    # remove the actor class constants to simulate the no-Actors load path.
    Legion::Extensions.send(:remove_const, :Actors)

    %i[FullScan DeltaScan ObserverTick].each do |name|
      Legion::Extensions::Detect::Actor.send(:remove_const, name) if
        Legion::Extensions::Detect::Actor.const_defined?(name, false)
    end
  end

  after(:all) do
    # Restore the Actors stub so subsequent spec files are unaffected.
    actors = Module.new
    once_class = Class.new do
      def initialize(**_opts); end

      def runner_class = self.class
    end
    every_class = Class.new do
      def initialize(**_opts); end

      def runner_class = self.class
    end
    actors.const_set(:Once, once_class)
    actors.const_set(:Every, every_class)
    Legion::Extensions.const_set(:Actors, actors)
  end

  it 'does not define actor classes when Actors is absent' do
    expect(Legion::Extensions::Detect::Actor.const_defined?(:FullScan, false)).to be false
    expect(Legion::Extensions::Detect::Actor.const_defined?(:DeltaScan, false)).to be false
    expect(Legion::Extensions::Detect::Actor.const_defined?(:ObserverTick, false)).to be false
  end

  it 'still provides the .scan public API' do
    allow(Legion::Extensions::Detect::Scanner).to receive(:scan).and_return([])
    expect(Legion::Extensions::Detect.scan).to eq([])
  end

  it 'still provides the .missing public API' do
    allow(Legion::Extensions::Detect::Scanner).to receive(:scan).and_return([])
    expect(Legion::Extensions::Detect.missing).to eq([])
  end

  it 'still provides the .catalog public API' do
    expect(Legion::Extensions::Detect.catalog).to be_an(Array)
    expect(Legion::Extensions::Detect.catalog).not_to be_empty
  end
end
