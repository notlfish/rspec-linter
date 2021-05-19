require_relative 'tree_structs'
require 'colorize'

def report_error(error)
  location = "#{error[:line]}, #{error[:column]}".colorize(:yellow)
  message = "\t#{location}: #{error[:message]}"
  rule = "#{error.kind}/#{error[:rule]}".colorize(:blue)
  "\n#{message}:\t\trule:[#{rule}]"
end

def report(errors)
  return if errors.empty?

  errors.sort! do |err1, err2|
    lines = err1.line - err2.line
    return lines unless lines.zero?

    err1.column - err2.column
  end
  errors.map(&:report_error).join('\n')
end

def create_error(message, rule, node)
  { message: message,
    line: node.line,
    column: node.column,
    kind: node.class,
    rule: rule }
end

class Rules
  def initialize
    @rules = []
  end

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
  def rspec_filename(toplevel)
    message = "Toplevel name should end with '_spec.rb'"
    cond = toplevel.filename&.end_with?('_spec.rb')
    create_error(message, :rspec_filename, toplevel) unless cond
  end

  def entry_point(toplevel)
    message = 'All tests should be grouped in one describe'
    conditions = []
    conditions[0] = toplevel.expressions.length == 1
    conditions[1] = toplevel.expressions[0].is_a? Describe
    create_error(message, :entry_point, toplevel) unless conditions.all?
  end

  def initialize
    super
    @rules.push(:rspec_filename)
    @rules.push(:entry_point)
  end
end

class DescribeRules < Rules
  def class_or_method_message(describe)
    message = 'describe message should only contain the name of the class or method being tested'
    conds = [false]
    unless describe.message.empty?
      conds[0] = describe.message.split.length == 1
      first = describe.message[0]
      conds[1] = '.#'.include?(first) || /[[:upper:]]/.match(first)
    end
    create_error(message, :class_or_method_message, describe) unless conds.all?
  end

  def initialize
    super
    @rules.push(:class_or_method_message)
  end
end

class ContextRules < Rules
  def first_word(context)
    first_word = %w[when with without]
    cond = first_word.include? context.message.split[0]
    message = 'context message should begin with "when", "with", or "without"'
    create_error(message, :first_word, context) unless cond
  end

  def initialize
    super
    @rules.push(:first_word)
  end
end

class ItRules < Rules
  def one_expectation(test)
    message = 'it should contain exactly one expectation'
    cond = test.content.length == 1 && test.content[0].is_a?(Expectation)
    create_error(message, :one_expectation, test) unless cond
  end

  def initialize
    super
    @rules.push(:one_expectation)
  end
end

class ExpectationRules < Rules; end
