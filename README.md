# Rus^3

[![Build Status](https://github.com/mnbi/rus3/workflows/Build/badge.svg)](https://github.com/mnbi/rus3/actions?query=workflow%3A"Build")

Ruby with Syntax Sugar of Scheme.
Or a simple translator from Scheme program to Ruby.

## Installation

Execute as:

    > gem install rus3

## Usage

You can start the Rus3 REPL with the command, `rus3`.

``` scheme
> rus3
A simple REPL for Rus3:
- Rus3 version: 0.1.0
  - REPL version: 0.1.0
    - Parser version 0.1.0 ((scheme-parser-version . 0.1.0) (scheme-lexer-version . 0.1.0))
    - Evaluator version: 0.1.0
    - using built-in PRINTER
Rus3(scheme)>
```

`Rus3(scheme)>` is the prompt of the Rus3.

In the REPL, you can enter Scheme expressions.  The REPL reads your
Scheme expressions, translates it to Ruby expressions, and
evaluated them.  Then, the REPL prints the result after `==> `.

### Literal of Scheme values

Boolean (`#f` and `#t`), an empty list (`()`), a string, and numbers
(integer, real, rational and complex) can be translated.

``` scheme
Rus3(scheme)> #f
==> false
Rus3(scheme)> #t
==> true
Rus3(scheme)> ()
==> []
Rus3(scheme)> "foo"
==> "foo"
Rus3(scheme)> 123.456
==> 123.456
Rus3(scheme)> 1/9
==> (1/9)
Rus3(scheme)> 3+4i
==> (3+4i)
```

### Procedure call

You can apply a defined procedure.

``` scheme
Rus3(scheme)> (list 1 2 3)
==> [1, 2, 3]
Rus3(scheme)> (append (list 1 2 3) (list 4 5 6))
==> [1, 2, 3, 4, 5, 6]
```

### Lambda expression

You can apply lambda expression as a procedure.

``` scheme
Rus3(scheme)> ((lambda (x) (* x x)) 2)
==> 4
```

### Conditional expression

``` scheme
Rus3(scheme)> (if (< 2 3) "true" "false")
==> "true"
```

`cond` type is also available.

### Assignment

``` scheme
Rus3(scheme)> (set! x 2)
==> 2
Rus3(scheme)> x
==> 2
```

### Define a procedure

``` scheme
Rus3(scheme)> (define (fact n) (if (= n 0) 1 (* n (fact (- n 1)))))
==> :fact
Rus3(scheme)> (fact 5)
==> 120
```

### Let expression

``` scheme
Rus3(scheme)> (let ((x 2) (y 3)) (* x y))
==> 6
```

## Procedures in the Scheme specification (R5RS or R7RS-small)

Following procedures described in the spec is available.

- Predicates:
  - null?, list?
  - eqv?, eq?
  - boolean?, pair?, symbol?, number?, string?
    - char?, vector?, and port? are defined but it always returns `false`.
  - complex?, real?, rational?, integer?
  - zero?, positive?, negative?, odd?, even?
  - string-eq?, string-ci-eq?, string-lt?, string-gt?, string-le?,
    string-ge?, string-ci-lt?, string-ci-gt?, string-ci-le?, string-ci-ge?
  - some predicates for `char` and `port` are defined but it always
    returns `false`.

- List operations
  - cons, car, cdr, set-car!, set-cdr!, cxxr (caar and so on)
  - list, length, append, reverse, list-tail, list-ref

- Write values
  - write
  - display

- Control features
  - map
  - zip

## System interface

### Load-scm procedure

Reads a Scheme program file, then translates and evaluates.

``` scheme
Rus3(scheme)> (load-scm "examples/iota.scm")
(1 2 3 4 5 6 7 8 9 10)
(1/9 2/9 1/3 4/9 5/9 2/3 7/9 8/9 1/1 10/9)
==> #<Rus3::Undef:0x00007f90f8945418>
```

## Restrictions

In the current version, there are several restrictions, those are
deviations from the Scheme specification (R5RS or R7RS-small).

- `Equal?` does not defined.  Since `Object#equal?` must not re-define
  in Ruby.
- `Cdr` and `list-tail` do not return a reference of the part of the
  target list.  They return a new list structure which contains the
  same member of the target list.
- Rus3 would replace some character which can not use as a part of
  identifier in Ruby.  So, it is possible that some collision of
  identifiers.
- Nested definition of procedure can use outside.

Some of these may be disappeared in the future version, or may not be.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/mnbi/rus3](https://github.com/mnbi/rus3).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
