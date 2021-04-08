#!/usr/bin/env ruby
# frozen_string_literal: true

RUS3_DEBUG = !ARGV.shift.nil?
require "rus3"
include Rus3

if Rus3.debug_mode?
  pp self.class.included_modules
end

def iota_int(count, start = 0, step = 1)
  if zero?(count)
    EMPTY_LIST
  else
    cons(start, iota_int(count - 1, start + step, step))
  end
end

l0 = iota_int(5)
display(l0)
