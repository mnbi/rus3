(define (iota-iter result count start step)
  (if (zero? count)
      result
      (iota-iter (append result (list start))
		 (- count 1)
		 (+ start step)
		 step)))

(define (iota count start step)
  (iota-iter () count start step))

(display (iota 10 1 1))
(display (iota 10 1/9 11/99))
