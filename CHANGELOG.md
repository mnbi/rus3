# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/)
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]
- (nothing to record here)

## [0.2.1] - 20201-05-20
### Changed
- Use Rbscmlex instead of built-in lexer. (#6)
- Use Rubasteme instead of built-in AST and parser. (#6)

### Fixed
- Fix #5: too old `required_ruby_version`.

## [0.2.0] - 2021-05-03
### Added
- Re-write the parser and evaluator mechanism.
- Add tests for SchemeParser and Translator.
- Add a mechanism to replace comparison operator characters in
  identifiers.
  - e.g. `char<?` -> `char_lt?`

## [0.1.2] - 2021-04-23
### Added
- Add `char`:
  - add Rus3::Char class,
  - modify Rus3::Parser::Lexer to accept a character literal,
  - modify Rus3::Parser::SchemeParser to parse and translate a
    character literal,
- Add new error classes (CharRequiredError),
- Add tests around `char`.

## [0.1.1] - 2021-04-22
### Added
- Add `vector`:
  - add Rus3::Vector class,
  - modify Rus3::Parser::Lexer to accept a vector literal,
  - modify Rus3::Parser::SchemeParser to parse and translate a vector
    literal,
- Add new error classes (VectorRequiredError and ExceedUpperLimitError),
- Add tests around `vector`.

### Changed
- Modify Rus3::Parser::Lexer to convert "->" to "_to_",
  - now, the Scheme identifier such "list->vector" is usable in the
    REPL

## [0.1.0] - 2021-04-21
- Initial release:
  - Rus3 can translate fundamental syntax of Scheme into Ruby.
