Toplevel = Struct.new(:expressions) do
  attr_reader :filename

  def add_name(filename)
    @filename = filename
  end

  def lint(linter)
    rules = linter.rules[:toplevel]
    errors = rules.run(self)
    expressions.each { |node| errors += node.lint(linter) }
    errors
  end
end

Describe = Struct.new(:message, :content, :line, :column) do
  def lint(linter)
    rules = linter.rules[:describe]
    errors = rules.run(self)
    content.each { |node| errors += node.lint(linter) }
    errors
  end
end

Context_ = Struct.new(:message, :content, :line, :column) do
  def lint(linter)
    rules = linter.rules[:context]
    errors = rules.run(self)
    content.each { |node| errors += node.lint(linter) }
    errors
  end
end

It = Struct.new(:message, :content, :line, :column) do
  def lint(linter)
    rules = linter.rules[:it]
    errors = rules.run(self)
    content.each { |node| errors += node.lint(linter) }
    errors
  end
end

Expectation = Struct.new(:content, :line, :column) do
  def lint(linter)
    rules = linter.rules[:expectation]
    rules.run(self)
  end
end
