#!/usr/bin/env ruby
# frozen_string_literal: true

# (define (fib n)
#   (cond ((= n 0) 0)
# 	((= n 1) 1)
# 	(else (+ (fib (- n 1)) (fib (- n 2))))))

def fib(n)
  if n == 0
    0
  elsif n == 1
    1
  else
    fib(n - 1) + fib(n - 2)
  end
end

puts fib(10)

# (define (fib-iter n f0 f1)
#   (cond ((= n 0) f0)
# 	((= n 1) f1)
# 	(else (fib-iter (- n 1) f1 (+ f0 f1)))))

def fib_iter(n, f0, f1)
  if n == 0
    f0
  elsif n == 1
    f1
  else
    fib_iter((n - 1), f1, (f0 + f1))
  end
end

puts fib_iter(100, 0, 1)
