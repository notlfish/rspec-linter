require 'spec_helper'
require 'parslet'
require_relative '../lib/parser'
require_relative '../lib/tree_structs'

def parse_transform(code)
  parser = TestsParser.new
  transformer = TestsTransform.new
  transformer.apply(parser.parse(code))
end

RSpec.describe 'TestsParser' do
  let(:expectation) { parse_transform('expect(1+2).to eq(3)') }
  let(:it_expect) do
    parse_transform(
      <<~TEST2
        it 'has more than one expectation' do
          expect(1 + 2).to eq(3)
          expect 'nobody expects the Spanish Inquisition!'
        end
      TEST2
    )
  end

  let(:full_nested) do
    parse_transform(
      <<~TEST1
        describe '#rspec' do
          context 'when something random' do
            it 'has more than one expectation' do
              a = 11
              expect(1 + 2).to eq(3)
              expect 'nobody expects the Spanish Inquisition!'
            end
          end
        end
      TEST1
    )
  end

  describe 'TestsTransform' do
    context 'when parsing one expectation' do
      it 'toplevel has only one expression' do
        expect(expectation.expressions.length).to eq(1)
      end

      it 'toplevel has one expectation' do
        expectations = expectation.expressions.count do |exp|
          exp.is_a? Expectation
        end
        expect(expectations).to eq(1)
      end
    end

    context 'when parsing it with two expectations' do
      it 'toplevel has one it' do
        its = it_expect.expressions.count do |exp|
          exp.is_a? It
        end
        expect(its).to eq(1)
      end

      it 'toplevel > it has two expectations' do
        it_expectations = it_expect.expressions[0].content.count do |exp|
          exp.is_a? Expectation
        end
        expect(it_expectations).to eq(2)
      end
    end

    context 'when parsing describe > context > it > 2 expectations' do
      it 'toplevel has one describe' do
        describes = full_nested.expressions.count do |exp|
          exp.is_a? Describe
        end
        expect(describes).to eq(1)
      end

      it 'toplevel > describe has one context' do
        contexts = full_nested.expressions[0].content.count do |exp|
          exp.is_a? Context_
        end
        expect(contexts).to eq(1)
      end

      it 'toplevel > describe > context has one it' do
        its = full_nested.expressions[0].content[0].content.count do |exp|
          exp.is_a? It
        end
        expect(its).to eq(1)
      end

      it 'toplevel > describe > context has one it' do
        its = full_nested.expressions[0].content[0].content[0]
        expectations = its.content.count do |exp|
          exp.is_a? Expectation
        end
        expect(expectations).to eq(2)
      end
    end

    context 'when parsing an empty file' do
      it 'returns an empty toplevel' do
        expect(parse_transform('')).to eq(Toplevel.new([]))
      end
    end

    let(:broken) do
      parse_transform(
        <<~TEST1
          describe do
            context 'when something random' do
              it 'has more than one expectation' do
                a = 11
                expect(1 + 2).to eq(3)
                expect 'nobody expects the Spanish Inquisition!'
              end
            end
          end
      TEST1
      )
    end
    context 'when parsing a broken file' do
      it 'raises an error' do
        expect { parse_transform(broken) }.to raise_error(ArgumentError)
      end
    end
  end
end
