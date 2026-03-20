# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Detect::Runners::CancelTask do
  let(:canceller) { Class.new { include Legion::Extensions::Detect::Runners::CancelTask }.new }

  describe '#cancel_task' do
    context 'when Legion::Data is not available' do
      it 'returns failure' do
        result = canceller.cancel_task(task_id: 1)
        expect(result[:success]).to be false
        expect(result[:reason]).to eq(:data_unavailable)
      end
    end
  end
end
