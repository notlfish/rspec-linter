require_relative 'tree_structs'
require 'colorize'

def report_error(line, column, message)
  location = "#{line}, #{column}".colorize(:yellow)
  "\t#{location}: #{message}"
end

class Rules
  def initialize
    @rules = []
  end

  def run(node)
    errors = ''
    @rules.each do |rule|
      message = send(rule, node)
      report = "\n#{message}:\t\trule:[#{rule.to_s.colorize(:green)}]"
      errors += report unless message.nil?
    end
    errors
  end
end

class ToplevelRules < Rules
  def rspec_filename(toplevel)
    message = "Toplevel name should end with '_spec.rb'"
    report_error(0, 0, message) unless toplevel.filename.end_with? '_spec.rb'
  end

  def entry_point(toplevel)
    message = 'All tests should be grouped in one describe'
    conditions = []
    conditions[0] = toplevel.expressions.length == 1
    conditions[1] = toplevel.expressions[0].is_a? Describe
    report_error(1, 1, message) unless conditions.all?
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
    conditions = []
    conditions[0] = describe.message.split.length == 1
    first = describe.message[0]
    conditions[1] = '.#'.include?(first) || /[[:upper:]]/.match(first)
    line = describe.line
    column = describe.column
    report_error(line, column, message) unless conditions.all?
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
    report_error(context.line, context.column, message) unless cond
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
    report_error(test.line, test.column, message) unless cond
  end
end

class ExpectationRules < Rules; end
