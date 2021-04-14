# frozen_string_literal: true

module Rus3::Parser

  # This lexical analyzer is based on the one in the book, "Writing An
  # Interpreter In Go".

  class Token

    TYPES = {
      # controls
      "illegal"       => :illegal,
      "eof"           => :eof,

      # delimiters
      "+"             => :plus,
      "-"             => :minus,
      "."             => :period,
      "("             => :lpraen,
      ")"             => :rparen,
      "'"             => :single_quote,
      "`"             => :back_quote,
      ","             => :comma,
      "\""            => :double_quote,
      "\\"            => :backslash,
      "["             => :lbracket,
      "]"             => :rbracket,
      "{"             => :lbrace,
      "}"             => :rbrace,
      "|"             => :vertical_bar,
      "#"             => :sharp,

      # keywords
      "define"        => :define,
      "set!"          => :set,
      "lambda"        => :lambda,
      "if"            => :if,
      "quote"         => :quote,
      "quasiquote"    => :quasiquote,
      "define-syntax" => :define_syntax,
      "let-syntax"    => :let_syntax,
      "syntax-rules"  => :syntax_rules,

      # vallue types
      "ident"         => :ident,
      "string"        => :string,
      "number"        => :number,
      "vector"        => :vector,
    }

    KEYWORDS = [
      "define", "set!", "lambda", "if", "quote", "'", "quasiquote", "`",
      "define-syntax", "let-syntax", "syntax-rules",
    ]

    class << self
      def lookup_ident(ident)
        KEYWORDS.include?(ident) ? TYPES[ident] : :ident
      end
    end

    def initialize(type, literal)
      @type = type
      @literal = literal
    end

  end

  # A class to convert Scheme expression into tokens.

  class Lexer

    class ScanError < Rus3::Error; end

    def initialize(input)
      @input = input
      @len = input.length
      @pos = 0
      @scan_pos = 0
      @char = nil

      scan_char
    end

    def next_token
      token = nil

      skip_whitespace

      case @char
      when "\""                 # start of a string
        token = scan_string
      when "+", "-"             # sign of a number
        token = scan_number
      when "("                  # start of a list
        token = Token.new(:lparen, @char)
      when ")"                  # end of a list
        token = Token.new(:rparen, @char)
      when "#"                  # start of #t, #f or a vector or ...
        # TODO: ...
      when "'"                  # start of quoted data
        # TODO: ...
      when "`"
        # TODO: ...
      when ","
        # TODO: ...
      when "\\"
        # TODO: ...
      when nil
        token = Token.new(:eof, "")
      else
        if is_digit?(@char)
          token = scan_number
        elsif is_alphabetic?(@char) or is_extended_alphabetic?(@char)
          token = scan_identifier
        else
          token = Token.new(:illegal, @char)
        end
      end

      scan_char
      token
    end

    def scan_char
      if @scan_pos >= @len
        @char = nil
      else
        @char = @input[@scan_pos]
      end
      @pos = @scan_pos
      @scan_pos += 1
    end

    def peek_char
      @scan_pos < @len ? @input[@scan_pos] : nil
    end

    def skip_whitespace
      scan_char while is_whitespace?(@char)
    end

    def is_whitespace?(char)
      !/\s/.match(char).nil?
    end

    def is_alphabetic?(char)
      !/[A-z]/.match(char).nil?
    end

    def is_digit?(char)
      !/\d/.match(char).nil?
    end

    # NOTE: See R5RS "2.1 Identifier" about extended alphabetic
    # characters.
    def is_extended_alphabetic?(char)
      !/[!$%&\*\+\-\.\/:<=>\?@\^_~]/.match(char).nil?
    end

    def is_id_character?(char)
      is_alphabetic?(@char) or is_digit?(@char) or is_extended_alphabetic?(@char)
    end

    def is_delimiter?(char)
      !/[\s()#"'`,\\]/.match(char).nil?
    end

    def is_sign?(char)
      !/[+\-]/.match(char).nil?
    end

    def scan_identifier
      pos = @pos
      scan_char while is_id_character?(@char)
      literal = @input[pos...@pos]

      type = Token.lookup_ident(literal)
      token = Token.new(type, literal)
    end

    def scan_string
      pos = @pos + 1
      loop {
        scan_char
        break if @char == "\"" or @char.nil?
      }
      Token.new(:string, @input[pos...@pos])
    end

    # NOTE: A number is represented in some notations.
    #
    #   digits     : <digit><digit>...<digit>
    #   real       : <digits>.<digits>
    #   rational   : <real>/<real>
    #   complex (1): <rational>+<rational>i or <rational>+i
    #   complex (2): <rational>-<rational>i or <rational>-i
    #   complex (3): <rational>@<rational>

    def scan_number
      begin
        pos = @pos
        scan_char if is_sign?(@char)
        raise ScanError, @input[pos...@pos] unless is_digit?(@char)
        skip_rational_number

        case @char
        when "+", "-"
          scan_char

          if is_digit?(@char)
            skip_rational_number

            if @char == "i"
              scan_char
            else
              raise ScanError, @input[pos...@pos]
            end

          elsif @char == "i"
            scan_char
          else
            raise ScanError, @input[pos...@pos]
          end
        when "@"             # complex number: <rat>@<rat>
          scan_char
          if is_digit?(@char)
            skip_rational_number
          else
            raise ScanError, @input[pos...@pos]
          end
        else
          raise ScanError, @input[pos...@pos] unless is_delimiter?(@char)
        end

      rescue ScanError => _
        Token.new(:illegal, @input[pos...@pos])
      else
        Token.new(:number, @input[pos...@pos])
      end
    end

    def skip_rational_number
      # <real>(/<real>)
      pos = @pos
      skip_real_number
      if @char == "/"
        if is_digit?(peek_char)
          scan_char
          skip_real_number
        else
          raise ScanError, @input[pos...@pos]
        end
      elsif !is_delimiter?(@char) and !"+-i@".include?(@char)
        raise ScanError, @input[pos...@pos]
      end
    end

    def skip_digits
      scan_char while is_digit?(@char)
    end

    def skip_real_number
      # <digits>(.<digits>)
      pos = @pos
      skip_digits
      if @char == "."
        if is_digit?(peek_char)
          scan_char
          skip_digits
        else
          raise ScanError, @input[pos...@pos]
        end
      elsif !is_delimiter?(@char) and !"/+-i@".include?(@char)
        raise ScanError, @input[pos...@pos]
      end
    end

  end
end
