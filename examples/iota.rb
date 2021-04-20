#!/usr/bin/env ruby
# frozen_string_literal: true

require "rus3"
include Rus3

# (define (iota count start step)
#   (if (zero? count)
#       ()
#       (cons start (iota (- count 1) (+ start step) step))))
def iota(count, start = 0, step = 1)
  if zero?(count)
    EMPTY_LIST
  else
    cons(start, iota(count - 1, start + step, step))
  end
end

l0 = iota(5)
display(l0)

l1 = iota(10, 3.14, 0.01)
display(l1)

l2 = iota(20, Rational(1, 9), Rational(1, 99))
display(l2)

# (define (iota-tr count start step)
#   (iota-tr-iter count () start step))
#
# (define (iota-tr-iter result count start step)
#   (if (zero? count)
#       result
#       (iota-tr-iter (append result (list start))
#                     (- count 1)
#                     (+ start step)
#                     step)))
def iota_tr(count, start = 0, step = 1)
  iota_tr_iter(EMPTY_LIST, count, start, step)
end

def iota_tr_iter(result, count, start, step)
  if zero?(count)
    result
  else
    iota_tr_iter(append(result, list(start)), count - 1, start + step, step)
  end
end

l3 = iota_tr(30)
display(l3)
