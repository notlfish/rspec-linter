require_relative '../lib/rules'
require_relative '../lib/tree_structs'
require 'colorize'

RSpec.describe 'Linter' do
  let(:linter) do
    Struct.new(:rules).new({ toplevel: ToplevelRules.new,
                             describe: DescribeRules.new,
                             context: ContextRules.new,
                             it: ItRules.new,
                             expectation: ExpectationRules.new })
  end

  describe 'ToplevelRules' do
    let(:clean_top) do
      top = Toplevel.new([Describe.new('Class', [], 1, 1)])
      top.add_name('clean_spec.rb')
      top
    end

    context 'when there are no linting errors' do
      it 'empty linting errors list' do
        expect(clean_top.lint(linter)).to eq([])
      end
    end

    let(:bad_name_top) do
      top = Toplevel.new([Describe.new('Class', [], 1, 1)])
      top.add_name('clean_test.rb')
      top
    end

    context 'when toplevel has bad name' do
      it 'one linting error' do
        expect(bad_name_top.lint(linter).length).to eq(1)
      end

      it ':rspec_filename error' do
        error_rule = bad_name_top.lint(linter)[0][:rule]
        expect(error_rule).to eq(:rspec_filename)
      end
    end

    let(:many_entry_points) do
      test_suite = Describe.new('Class', [], 1, 1)
      top = Toplevel.new([test_suite, test_suite])
      top.add_name('clean_spec.rb')
      top
    end

    context 'when toplevel has more than one entry point' do
      it 'one linting error' do
        expect(many_entry_points.lint(linter).length).to eq(1)
      end

      it ':entry_point error' do
        error_rule = many_entry_points.lint(linter)[0][:rule]
        expect(error_rule).to eq(:entry_point)
      end
    end
  end

  describe 'DescribeRules' do
    let(:clean_describe) { Describe.new('Class', [], 1, 1) }

    context 'when there are no linting errors' do
      it 'empty linting errors list' do
        expect(clean_describe.lint(linter)).to eq([])
      end
    end

    let(:bad_name_empty) { Describe.new('', [], 1, 1) }

    context 'when empty name' do
      it 'one linting error' do
        expect(bad_name_empty.lint(linter).length).to eq(1)
      end
    end

    let(:bad_name_many) { Describe.new('Two Classes', [], 1, 1) }

    context 'when name has many words' do
      it 'one linting error' do
        expect(bad_name_many.lint(linter).length).to eq(1)
      end

      it ':class_or_method_message error' do
        error_rule = bad_name_many.lint(linter)[0][:rule]
        expect(error_rule).to eq(:class_or_method_message)
      end
    end

    let(:bad_name_first_letter) { Describe.new('method', [], 1, 1) }

    context 'when name does not begin with "#", "." or an uppercase' do
      it 'one linting error' do
        expect(bad_name_first_letter.lint(linter).length).to eq(1)
      end

      it ':class_or_method_message error' do
        error_rule = bad_name_first_letter.lint(linter)[0][:rule]
        expect(error_rule).to eq(:class_or_method_message)
      end
    end
  end

  describe 'ContextRules' do
    let(:clean_context) { Context_.new('when clean context', [], 1, 1) }

    context 'when there are no linting errors' do
      it 'empty linting errors list' do
        expect(clean_context.lint(linter)).to eq([])
      end
    end

    let(:bad_message_context) { Context_.new('something happened', [], 1, 1) }

    context "when message doesn't begin with 'with', 'without', or 'when'" do
      it 'one linting error' do
        expect(bad_message_context.lint(linter).length).to eq(1)
      end

      it ':first_word error' do
        error_rule = bad_message_context.lint(linter)[0][:rule]
        expect(error_rule).to eq(:first_word)
      end
    end
  end

  describe 'ItRules' do
    let(:clean_it) do
      expectation = Expectation.new('expect(1 + 2).to eq(3)', 2, 2)
      It.new('simple addition', [expectation], 1, 1)
    end

    context 'when there are no linting errors' do
      it 'empty linting errors list' do
        expect(clean_it.lint(linter)).to eq([])
      end
    end

    let(:no_expectations_it) { It.new('useless example', [], 1, 1) }

    context 'when there are no expectations' do
      it 'one linting error' do
        expect(no_expectations_it.lint(linter).length).to eq(1)
      end

      it ':one_expectation error' do
        error_rule = no_expectations_it.lint(linter)[0][:rule]
        expect(error_rule).to eq(:one_expectation)
      end
    end
  end
end
