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

var source: String = ''
var reporter = null
var tokens: Array = []

var _had_error: bool = false
var _source_len = 0
var _start_idx = 0
var _start_line = 0
var _start_column = 0
var _idx = 0
var _line = 0
var _column = 0


func had_error() -> bool:
	return _had_error

func lex() -> void:
	_pre_lex()

	while not _eof():
		_start_idx = _idx
		_start_line = _line
		_start_column = _column
		_lex_token()

	tokens.append(Token.new(
		Token.Type.EOF,
		_line, _column,
		_line, _column,
		_idx, _idx,
		null
	))

func _pre_lex() -> void:
	_source_len = source.length()
	_idx = 0
	_start_idx = 0
	_start_line = 0
	_start_column = 0
	_line = 0
	_column = 0
	_had_error = false
	tokens.clear()

func _lex_token() -> void:
	var c: String = _advance()
	if c ==  '\\': _add_token(Token.Type.BACK_SLASH)
	elif c == '/': _add_token(Token.Type.SLASH)
	elif c == '(': _add_token(Token.Type.PAREN_OPEN)
	elif c == ')': _add_token(Token.Type.PAREN_CLOSE)
	elif c == '{': _add_token(Token.Type.CURLY_OPEN)
	elif c == '}': _add_token(Token.Type.CURLY_CLOSE)
	elif c == '[': _add_token(Token.Type.BRACK_OPEN)
	elif c == ']': _add_token(Token.Type.BRACK_CLOSE)
	elif c == '+': _add_token(Token.Type.PLUS)
	elif c == '-': _add_token(Token.Type.MINUS)
	elif c == '*': _add_token(Token.Type.STAR)
	elif c == ':': _add_token(Token.Type.COLON)
	elif c == '=': _add_token(Token.Type.EQUAL_EQUAL if _match('=') else Token.Type.EQUAL)
	elif c == '>': _add_token(Token.Type.GREATER_THAN_EQUAL if _match('=') else Token.Type.GREATER_THAN)
	elif c == '<': _add_token(Token.Type.LESS_THAN_EQUAL if _match('=') else Token.Type.LESS_THAN)
	elif c == '!': _add_token(Token.Type.NOT_EQUAL if _match('=') else Token.Type.NOT)
	elif c == '&' and _match('&'): _add_token(Token.Type.AND)
	elif c == '|' and _match('|'): _add_token(Token.Type.OR)
	elif c == '#': _comment()
	elif c == '"' or c == "'": _string(c)
	elif c.is_valid_integer(): _number()
	elif c.is_valid_identifier(): _identifier()
	elif c == '\n': _newline()
	elif c == '\r': pass
	else:
		_error('Unknown character.')

func _eof():
	return _idx >= _source_len

func _consume() -> void:
	_idx += 1
	_column += 1

func _advance() -> String:
	_consume()
	return source[_idx - 1]

func _peek() -> String:
	return '' if _eof() else source[_idx]

func _match(c: String) -> bool:
	if _eof(): return false
	if source[_idx] != c: return false

	_consume()
	return true

func _comment() -> void:
	while _peek() != '\n' and _peek() != '':
		_consume()
	_add_token(Token.Type.COMMENT)

func _number() -> void:
	while _peek().is_valid_integer():
		_consume()

	if _match('.'):
		if not _peek().is_valid_integer():
			_error('Numbers cannot end with a ".".')
		
		while _peek().is_valid_integer():
			_consume()

		var literal = float(source.substr(_start_idx, _idx - _start_idx))
		_add_token(Token.Type.FLOAT, literal)

		return
	
	var literal = int(source.substr(_start_idx, _idx - _start_idx))
	_add_token(Token.Type.INTEGER, literal)

func _identifier() -> void:
	# is_valid_identifier() will return
	# - false if _peek() is in DIGITS.
	# - true if _peek() is '_'
	while _peek().is_valid_identifier() or (_peek() in DIGITS):
		_consume()
	
	var literal = source.substr(_start_idx, _idx - _start_idx)
	var token_type = KEYWORDS.get(literal, Token.Type.IDENTIFIER)
	if token_type != Token.Type.IDENTIFIER:
		# Literals for keywords are superfluous.
		literal = null
	_add_token(token_type, literal)


func _string(open_quote: String) -> void:
	var c: String
	var no_closing_quote: bool = true
	while not _eof():
		c = _advance()
		if c == open_quote:
			no_closing_quote = false
			break
		elif c == '\\' and _match(open_quote):
			pass
		elif c == '\n':
			_line += 1
			_column = 0


	if no_closing_quote:
		_error('Unterminated string.')

	var content_start_idx = _start_idx + 1
	var content_count = _idx - content_start_idx - 1
	var literal = source.substr(content_start_idx, content_count)
	_add_token(Token.Type.STRING_CONTENT, literal)


func _newline() -> void:
	# The new _line has already been consumed here.
	_line += 1
	_column = 0

	# Get indents.
	while not _eof():
		var c: String = _peek()
		if c != ' ' and c != '\t':
			break

		# Get space indents.
		_start_idx = _idx
		_start_column = _column
		_start_line = _line
		while _match(' '): pass
		if _start_idx != _idx:
			_add_token(Token.Type.SPACE_INDENT, _idx - _start_idx)

		# Get tab indents.
		_start_idx = _idx
		_start_column = _column
		_start_line = _line
		while _match('\t'): pass
		if _start_idx != _idx:
			_add_token(Token.Type.TAB_INDENT, _idx - _start_idx)

func _add_token(type: int, literal=null) -> void:
	tokens.append(Token.new(type, _start_line, _start_column, _line, _column,
		_start_idx, _idx, literal))

func _error(message: String) -> void:
	_had_error = true
	if not reporter:
		return
	reporter.report(message, _start_idx, _idx, _line, _column)
