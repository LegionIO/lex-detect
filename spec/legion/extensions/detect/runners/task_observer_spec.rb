# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Detect::Runners::TaskObserver do
  let(:observer) { described_class }

  describe '#build_failure_pattern' do
    it 'returns failure pattern hash' do
      result = observer.send(:build_failure_pattern, 'lex-test', 'TestRunner', 'NoMethodError',
                             %w[line1 line2], 5)
      expect(result[:gem_name]).to eq('lex-test')
      expect(result[:failure_count]).to eq(5)
      expect(result[:runner_class]).to eq('TestRunner')
    end
  end

  describe '#extract_gem_name' do
    it 'converts runner class to gem name' do
      result = observer.send(:extract_gem_name, 'Legion::Extensions::Detect::Runners::TaskObserver')
      expect(result).to eq('lex-detect')
    end

    it 'returns nil for nil input' do
      expect(observer.send(:extract_gem_name, nil)).to be_nil
    end

    it 'returns nil when no Extensions segment' do
      expect(observer.send(:extract_gem_name, 'SomeOtherClass')).to be_nil
    end
  end

  describe '#check_and_publish_failure_patterns' do
    it 'does nothing when Legion::Data is not defined' do
      expect { observer.send(:check_and_publish_failure_patterns, []) }.not_to raise_error
    end

    it 'skips runners with fewer than 3 failures' do
      tasks = [
        { status: 'failed', runner_class: 'TestRunner', error_class: 'RuntimeError' },
        { status: 'failed', runner_class: 'TestRunner', error_class: 'RuntimeError' }
      ]
      expect { observer.send(:check_and_publish_failure_patterns, tasks) }.not_to raise_error
    end
  end
end
