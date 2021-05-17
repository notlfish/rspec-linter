require_relative 'parser'
require 'colorize'

def report_error(line, column, message)
  location = "#{line}, #{column}".colorize(:yellow)
  "\t#{location}: #{message}"
end

class TopRules
  @rules = [one_entry]

  def initialize; end

  def one_entry(toplevel)
    message = 'An rspec file should have one toplevel group of tests'
    report_error(1, 1, message) unless (toplevel.expressions.length == 1)
  end

  def describe_entry(toplevel); end
end
