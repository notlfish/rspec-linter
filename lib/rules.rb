require_relative 'tree_structs'
require 'colorize'

class Rules
  private

  def create_error(message, rule, node)
    { message: message,
      line: node.line,
      column: node.column,
      kind: node.class,
      rule: rule }
  end

  def initialize
    @rules = []
  end

  public

  def run(node)
    errors = []
    @rules.each do |rule|
      error = send(rule, node)
      errors.push(error) if error
    end
    errors
  end
end

class ToplevelRules < Rules
  private

  def rspec_filename(toplevel)
    message = "Test file names should end with '_spec.rb'"
    cond = toplevel.filename&.end_with?('_spec.rb')
    create_error(message, :rspec_filename, toplevel) unless cond
  end

  def entry_point(toplevel)
    method = 'describe'.colorize(:light_magenta)
    message = "All tests should be grouped in one #{method}"
    conditions = []
    conditions[0] = toplevel.expressions.length == 1
    conditions[1] = toplevel.expressions[0].is_a? Describe
    create_error(message, :entry_point, toplevel) unless conditions.all?
  end

  public

  def initialize
    super
    @rules.push(:rspec_filename)
    @rules.push(:entry_point)
  end
end

class DescribeRules < Rules
  private

  def class_or_method_message(describe)
    method = 'describe'.colorize(:light_magenta)
    message = "#{method} message should only contain the name of the class or method being tested"
    conds = [false]
    unless describe.message.empty?
      conds[0] = describe.message.split.length == 1
      first = describe.message[0]
      conds[1] = '.#'.include?(first) || /[[:upper:]]/.match(first)
    end
    create_error(message, :class_or_method_message, describe) unless conds.all?
  end

  public

  def initialize
    super
    @rules.push(:class_or_method_message)
  end
end

class ContextRules < Rules
  private

  def first_word(context)
    first_word = %w[when with without]
    cond = first_word.include? context.message.split[0]
    method = 'context'.colorize(:light_magenta)
    message = "#{method} message should begin with 'when', 'with', or 'without'"
    create_error(message, :first_word, context) unless cond
  end

  public

  def initialize
    super
    @rules.push(:first_word)
  end
end

class ItRules < Rules
  private

  def one_expectation(test)
    method = 'it'.colorize(:light_magenta)
    message = "#{method} should contain exactly one expectation"
    cond = test.content.length == 1 && test.content[0].is_a?(Expectation)
    create_error(message, :one_expectation, test) unless cond
  end

  public

  def initialize
    super
    @rules.push(:one_expectation)
  end
end

class ExpectationRules < Rules; end
