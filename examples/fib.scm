(define (fib-iter n f0 f1)
  (cond ((= n 0) f0)
 	((= n 1) f1)
 	(else (fib-iter (- n 1) f1 (+ f0 f1)))))

(define (fib n)
  (fib-iter n 0 1))

(fib 100)
