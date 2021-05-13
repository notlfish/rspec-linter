#!/usr/bin/env ruby

def test_file?(filename)
  %w[_test.rb _spec.rb].any? { |suffix| filename.end_with? suffix }
end
