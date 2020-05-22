# raku_lexer.gd
extends Reference

const Token = preload('raku_token.gd')

const KEYWORDS = {
	'not' : Token.Type.NOT,
	'and' : Token.Type.AND,
	'or' : Token.Type.OR,
	'if' : Token.Type.IF,
	'elif' : Token.Type.ELIF,
	'else' : Token.Type.ELSE,
	'while' : Token.Type.WHILE,
	'for' : Token.Type.FOR,
	'in' : Token.Type.IN,
	'true' : Token.Type.TRUE,
	'false' : Token.Type.FALSE,
}

const DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

var reporter = null

var source: String = ''
var tokens: Array = []
var had_error: bool = false

var source_len = 0
var start_idx = 0
var start_line = 0
var start_column = 0
var idx = 0
var line = 0
var column = 0

func pre_lex() -> void:
	source_len = source.length()
	idx = 0
	start_idx = 0
	start_line = 0
	start_column = 0
	line = 0
	column = 0
	had_error = false
	tokens.clear()

func lex() -> void:
	pre_lex()

	while not eof():
		start_idx = idx
		start_line = line
		start_column = column
		lex_token()

	tokens.append(Token.new(
		Token.Type.EOF,
		line, column,
		line, column,
		idx, idx,
		null
	))

func lex_token() -> void:
	var c: String = advance()
	if c ==  '\\': add_token(Token.Type.BACK_SLASH)
	elif c == '/': add_token(Token.Type.SLASH)
	elif c == '(': add_token(Token.Type.PAREN_OPEN)
	elif c == ')': add_token(Token.Type.PAREN_CLOSE)
	elif c == '{': add_token(Token.Type.CURLY_OPEN)
	elif c == '}': add_token(Token.Type.CURLY_CLOSE)
	elif c == '[': add_token(Token.Type.BRACK_OPEN)
	elif c == ']': add_token(Token.Type.BRACK_CLOSE)
	elif c == '+': add_token(Token.Type.PLUS)
	elif c == '-': add_token(Token.Type.MINUS)
	elif c == '*': add_token(Token.Type.STAR)
	elif c == ':': add_token(Token.Type.COLON)
	elif c == '=': add_token(Token.Type.EQUAL_EQUAL if check('=') else Token.Type.EQUAL)
	elif c == '>': add_token(Token.Type.GREATER_THAN_EQUAL if check('=') else Token.Type.GREATER_THAN)
	elif c == '<': add_token(Token.Type.LESS_THAN_EQUAL if check('=') else Token.Type.LESS_THAN)
	elif c == '!': add_token(Token.Type.NOT_EQUAL if check('=') else Token.Type.NOT)
	elif c == '&' and check('&'): add_token(Token.Type.AND)
	elif c == '|' and check('|'): add_token(Token.Type.OR)
	elif c == '#': comment()
	elif c == '"' or c == "'": string(c)
	elif c.is_valid_integer(): number()
	elif c.is_valid_identifier(): identifier()
	elif c == '\n': newline()
	elif c == '\r': pass
	else:
		error('Unknown character.')

func eof():
	return idx >= source_len

func consume() -> void:
	idx += 1
	column += 1

func advance() -> String:
	consume()
	return source[idx - 1]

func peek() -> String:
	return '' if eof() else source[idx]

func check(c: String) -> bool:
	if eof(): return false
	if source[idx] != c: return false

	consume()
	return true

func comment() -> void:
	while peek() != '\n' and peek() != '':
		consume()
	add_token(Token.Type.COMMENT)

func number() -> void:
	while peek().is_valid_integer():
		consume()

	if check('.'):
		if not peek().is_valid_integer():
			error('Numbers cannot end with a ".".')
		
		while peek().is_valid_integer():
			consume()

		var literal = float(source.substr(start_idx, idx - start_idx))
		add_token(Token.Type.FLOAT, literal)

		return
	
	var literal = int(source.substr(start_idx, idx - start_idx))
	add_token(Token.Type.INTEGER, literal)

func identifier() -> void:
	# is_valid_identifier() will return
	# - false if peek() is in DIGITS.
	# - true if peek() is '_'
	while peek().is_valid_identifier() or (peek() in DIGITS):
		consume()
	
	var literal = source.substr(start_idx, idx - start_idx)
	var token_type = KEYWORDS.get(literal, Token.Type.IDENTIFIER)
	if token_type != Token.Type.IDENTIFIER:
		# Literals for keywords are superfluous.
		literal = null
	add_token(token_type, literal)


func string(open_quote: String) -> void:
	var c: String
	var no_closing_quote: bool = true
	while not eof():
		c = advance()
		if c == open_quote:
			no_closing_quote = false
			break
		elif c == '\\' and check(open_quote):
			pass
		elif c == '\n':
			line += 1
			column = 0


	if no_closing_quote:
		error('Unterminated string.')

	var content_start_idx = start_idx + 1
	var content_count = idx - content_start_idx - 1
	var literal = source.substr(content_start_idx, content_count)
	add_token(Token.Type.STRING_CONTENT, literal)


func newline() -> void:
	# The new line has already been consumed here.
	line += 1
	column = 0

	# Get indents.
	while not eof():
		var c: String = peek()
		if c != ' ' and c != '\t':
			break

		# Get space indents.
		start_idx = idx
		start_column = column
		start_line = line
		while check(' '): pass
		if start_idx != idx:
			add_token(Token.Type.SPACE_INDENT, idx - start_idx)

		# Get tab indents.
		start_idx = idx
		start_column = column
		start_line = line
		while check('\t'): pass
		if start_idx != idx:
			add_token(Token.Type.TAB_INDENT, idx - start_idx)

func add_token(type: int, literal=null) -> void:
	tokens.append(Token.new(type, start_line, start_column, line, column,
		start_idx, idx, literal))

func error(message: String) -> void:
	had_error = true
	reporter.report(message, start_idx, idx, line, column)
