(define (fact n)
  (define (fact-iter n r c)
    (if (< n c)
	r
	(fact-iter n (* r c) (+ c 1))))
  (fact-iter n 1 1))

(display (fact 10))
(display (fact 100))
(display (fact 1000))
