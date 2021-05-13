#!/usr/bin/env ruby
require_relative '../lib/linter'

def test_file?(filename)
  %w[_test.rb _spec.rb].any? { |suffix| filename.end_with? suffix }
end

def arguments_usage
  <<~ARGS
    rspec-linter
    usage:
      rspec-linter: looks for test files in . and ./spec and runs the linter on them
      rspec-linter filename: runs the linter on ./filename'
  ARGS
end

def test_files(working_directory)
  tests = []
  files = Dir.children(working_directory)
  files.each { |filename| tests.push(filename) if test_file?(filename) }
  if files.include? 'spec'
    Dir.chdir('spec')
    tests += test_files(Dir.pwd)
  end
  tests
end

def run!
  case ARGV.length
  when 0
    Linter.new(test_files(Dir.pwd)).run!
  when 1
    Linter.new([ARGV[0]]).run!
  else
    puts arguments_usage
  end
end

run! if __FILE__ == $PROGRAM_NAME
