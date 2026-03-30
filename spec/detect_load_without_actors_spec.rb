# frozen_string_literal: true

# This spec verifies that legion/extensions/detect can be required safely
# in an environment where Legion::Extensions::Actors is NOT defined.
# The actors should be skipped (not loaded) and the public API must still work.
RSpec.describe 'Legion::Extensions::Detect without Actors' do
  before(:all) do
    # spec_helper defines Actors before requiring detect, so we must truly
    # simulate a no-Actors load by: removing the Actors constant, removing the
    # actor constants already defined on Detect::Actor, clearing the detect
    # entry point from $LOADED_FEATURES, and reloading it.
    Legion::Extensions.send(:remove_const, :Actors) if
      Legion::Extensions.const_defined?(:Actors, false)

    %i[FullScan DeltaScan ObserverTick].each do |name|
      Legion::Extensions::Detect::Actor.send(:remove_const, name) if
        Legion::Extensions::Detect::Actor.const_defined?(name, false)
    end

    # Clear the detect entry point and actor files from $LOADED_FEATURES so
    # the require below re-executes the `if defined?(Legion::Extensions::Actors)`
    # guard in a truly Actors-free environment.
    actor_dir = File.expand_path('../lib/legion/extensions/detect/actors', __dir__)
    entry     = File.expand_path('../lib/legion/extensions/detect.rb', __dir__)
    $LOADED_FEATURES.delete_if do |f|
      f == entry || f.start_with?("#{actor_dir}/")
    end

    require 'legion/extensions/detect'
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

    # Reload actor files so downstream specs that reference FullScan/DeltaScan/
    # ObserverTick find them defined (clear from $LOADED_FEATURES first).
    actor_dir = File.expand_path('../lib/legion/extensions/detect/actors', __dir__)
    %w[full_scan delta_scan observer_tick].each do |name|
      path = "#{actor_dir}/#{name}.rb"
      $LOADED_FEATURES.delete(path)
    end

    require_relative '../lib/legion/extensions/detect/actors/full_scan'
    require_relative '../lib/legion/extensions/detect/actors/delta_scan'
    require_relative '../lib/legion/extensions/detect/actors/observer_tick'
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
