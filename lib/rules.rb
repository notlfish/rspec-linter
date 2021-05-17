require_relative 'parser'
require 'colorize'

def report_error(line, column, message)
  location = "#{line}, #{column}".colorize(:yellow)
  "\t#{location}: #{message}"
end

Toplevel = Struct.new(:expressions) do
  def lint(linter); end
end
Describe = Struct.new(:message, :content, :line, :column) do
  def lint(linter); end
end
Context_ = Struct.new(:message, :content, :line, :column) do
  def lint(linter); end
end
It = Struct.new(:message, :content, :line, :column) do
  def lint(linter); end
end
Expectation = Struct.new(:content, :line, :column) do
  def lint(linter); end
end
