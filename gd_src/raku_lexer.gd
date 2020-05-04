# raku_lexer.gd
#
# TODO:
# - strings
# - numbers
# - idents
# - keywords
extends Reference

const Token = preload('raku_token.gd')

var reporter = null

var source: String = ''
var tokens: Array = []
var had_error: bool = false

var source_len = 0
var idx = 0
var start_idx = 0
var line = 0
var column = 0

func pre_lex() -> void:
	source_len = source.length()
	idx = 0
	start_idx = 0
	line = 1
	column = 0
	had_error = false
	tokens.clear()

func lex() -> void:
	pre_lex()

	while not eof():
		start_idx = idx
		lex_token()

	add_token(Token.Type.EOF)

func lex_token() -> void:
	var c: String = advance()
	if c ==  '\\': add_token(Token.Type.BACK_SLASH)
	elif c == '/': add_token(Token.Type.SLASH)
	elif c == '(': add_token(Token.Type.LEFT_PAREN)
	elif c == ')': add_token(Token.Type.RIGHT_PAREN)
	elif c == '{': add_token(Token.Type.LEFT_CURLY)
	elif c == '}': add_token(Token.Type.RIGHT_CURLY)
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
	elif c == '"' or c == "'": string()
	elif c == '\n': newline()
	elif c == '\r': pass
	else:
		error('Unknown character.')

func eof():
	return idx >= source_len

func advance() -> String:
	idx += 1
	column += 1
	return source[idx - 1]

func peek() -> String:
	return '' if eof() else source[idx]

func check(c: String) -> bool:
	if eof(): return false
	if source[idx] != c: return false

	# The following operations should match advance()
	idx += 1
	column += 1
	return true

func comment() -> void:
	while peek() != '\n' and peek() != '':
		advance()
	add_token(Token.Type.COMMENT)

func string() -> void:
	pass

func newline() -> void:
	line += 1
	column = 0

	# Get indents.
	while not eof():
		var c: String = peek()
		if c != ' ' and c != '\t':
			break

		# Get space indents.
		start_idx = idx
		while check(' '): pass
		if start_idx != idx: add_token(Token.Type.SPACE_INDENT)

		# Get tab indents.
		start_idx = idx
		while check('\t'): pass
		if start_idx != idx: add_token(Token.Type.TAB_INDENT)

func add_token(type: int, literal=null) -> void:
	tokens.append(Token.new(type, line, column, start_idx, idx, literal))

func error(message: String) -> void:
	had_error = true
	reporter.report(message, start_idx, idx, line, column)
