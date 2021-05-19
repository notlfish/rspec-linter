require 'spec_helper'
require_relative '../lib/rspec_linter'

RSpec.describe 'Rspec-linter' do
  describe '#test_file' do
    context 'when result is true' do
      it 'filename ends with _test.rb' do
        expect(test_file?('example_test.rb')).to be(true)
      end

      it 'filename ends with _spec.rb' do
        expect(test_file?('example_spec.rb')).to be(true)
      end
    end

    context 'when result is false' do
      it 'file is not a test file' do
        expect(test_file?('parser.rb')).to be(false)
      end
    end
  end
end
