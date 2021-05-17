require 'parslet'

class TestsParser < Parslet::Parser
  root(:top)

  rule(:top) { (skip? >> expression >> skip?).repeat.as(:top) >> eof }
  rule(:expression) { describe | context | it | expectation }

  rule(:describe) do
    describe_tag.as(:describe) >> string.as(:message) >> block.as(:block)
  end
  rule(:describe_tag) do
    space? >> (str('describe') | str('RSpec.describe')) >> space?
  end

  rule(:context) do
    context_tag.as(:c_tag) >> string.as(:message) >> block.as(:block)
  end
  rule(:context_tag) { space? >> str('context') >> space? }

  rule(:it) { it_tag.as(:it) >> string.as(:message) >> block.as(:block) }
  rule(:it_tag) { space? >> str('it') >> space? }

  rule(:block) { space? >> (do_block | braces_block) >> space? }
  rule(:do_block) do
    str('do') >>
      (str('end').absent? >> (expression | skip?)).repeat.as(:content) >>
      str('end')
  end
  rule(:braces_block) do
    str('{') >>
      (str('}').absent? >> (expression | skip?)).repeat.as(:content) >>
      str('}')
  end

  rule(:expectation) do
    space? >> ((str('expect(') | str('expect ')) >>
      ((newline | closing_tag).absent? >> any).repeat).as(:expectation)
  end

  rule(:skip?) { skip.maybe }
  rule(:skip) { ((expression | closing_tag).absent? >> any).repeat(1) }
  rule(:line) { space? >> (newline.absent? >> any).repeat >> newline }
  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }
  rule(:closing_tag) { str('end') | str('}') }

  rule(:eof) { any.absent? }
  rule(:string) { single_quoted_string | double_quoted_string }
  rule(:single_quoted_string) do
    str("'") >>
      (
        str('\\').ignore >> any |
        str("'").absent? >> any
      ).repeat >>
      str("'")
  end
  rule(:double_quoted_string) do
    str('"') >>
      (
        str('\\').ignore >> any |
        str('"').absent? >> any
      ).repeat >>
      str('"')
  end
  rule(:newline) { str("\n") >> str("\r").maybe }
end

Toplevel = Struct.new(:expressions)
Describe = Struct.new(:message, :content, :line, :column)
Context_ = Struct.new(:message, :content, :line, :column)
It = Struct.new(:message, :content, :line, :column)
Expectation = Struct.new(:content, :line, :column)

class TestsTransform < Parslet::Transform
  rule(top: subtree(:expressions)) { Toplevel.new(expressions) }
  rule(
    describe: simple(:tag),
    message: simple(:message),
    block: subtree(:content)
  ) do
    line, column = tag.line_and_column
    Describe.new(message, content[:content], line, column)
  end
  rule(
    c_tag: simple(:tag),
    message: simple(:message),
    block: subtree(:content)
  ) do
    line, column = tag.line_and_column
    Context_.new(message, content[:content], line, column)
  end
  rule(
    it: simple(:tag),
    message: simple(:message),
    block: subtree(:content)
  ) do
    line, column = tag.line_and_column
    It.new(message, content[:content], line, column)
  end
  rule(
    expectation: simple(:expectation)
  ) do
    line, column = expectation.line_and_column
    Expectation.new(expectation, line, column)
  end
end