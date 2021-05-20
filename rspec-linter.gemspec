Gem::Specification.new do |s|
  s.name = 'rspec-linter'
  s.version = '0.0.1'
  s.required_ruby_version = '>= 3.0.0'
  s.executables << 'rspec-linter'
  s.summary = 'Rspec code linter'
  s.description = 'A linter to enforce consistent styling of rspec tests'
  s.authors = ['Lucas Ferrari Soto']
  s.email = 'lcsfs11@gmail.com'
  s.files = ['lib/rspec_linter.rb',
             'lib/linter.rb',
             'lib/parser.rb',
             'lib/rules.rb',
             'lib/tree_structs.rb']
  s.homepage =
    'https://github.com/notlfish/rspec-linter'
  s.license = 'MIT'
end
