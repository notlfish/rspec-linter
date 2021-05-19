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
    return errors unless errors == "\n"

    success = 'no offenses'.colorize(:green)
    "\n#{@files.length} files inspected, #{success} detected"
  end
end
