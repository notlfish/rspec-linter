require 'colorize'
require_relative 'parser'
require_relative 'rules'

class Linter
  attr_reader :rules

  private

  def parse_transform(file)
    file_data = File.read(file)
    @transformer.apply(@parser.parse(file_data))
  end

  def report_error(error)
    location = "#{error[:line]}, #{error[:column]}".colorize(:yellow)
    message = "\t#{location}: #{error[:message]}"
    rule = "#{error[:kind]}/#{error[:rule]}".colorize(:blue)
    "#{message}: rule:[#{rule}]"
  end

  def report(errors)
    errors.sort! do |err1, err2|
      lines = err1[:line] - err2[:line]
      if lines.zero?
        err1[:column] - err2[:column]
      else
        lines
      end
    end
    (errors.map { |error| report_error(error) }).join("\n")
  end

  public

  def initialize(files)
    @files = files
    @rules = {}
    @rules[:toplevel] = ToplevelRules.new
    @rules[:describe] = DescribeRules.new
    @rules[:context] = ContextRules.new
    @rules[:it] = ItRules.new
    @rules[:expectation] = ExpectationRules.new
    @parser = TestsParser.new
    @transformer = TestsTransform.new
  end

  def run
    errors = "\n"
    @files.each do |file|
      tree = parse_transform(file)
      tree.add_name(file)
      file_errors = tree.lint(self)
      if file_errors.empty?
        print '.'
      else
        print 'F'
        errors += "\n#{file}\n#{report(file_errors)}" unless file_errors.empty?
      end
    end
    no_offenses = 'no offenses'.colorize(:green)
    success = "\n#{@files.length} files inspected, #{no_offenses} detected"
    errors == "\n" ? success : errors
  end
end
