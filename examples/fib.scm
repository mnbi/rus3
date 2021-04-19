(define (fib_iter n f0 f1)
  (cond ((= n 0) f0)
 	((= n 1) f1)
 	(else (fib_iter (- n 1) f1 (+ f0 f1)))))
