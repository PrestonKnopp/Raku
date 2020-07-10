extends Reference


const Token = preload('res://raku_token.gd')
const Lexer = preload('res://raku_lexer.gd')
const Ast = preload('res://raku_ast.gd')

var T = Token.Type

var reporter = null
var source = ''

var _lexer = Lexer.new()
var _root = null
var _idx = 0
var _had_error = false

var _indent_detected = T.EOF
# Detected indent should be either T.SPACE_INDENT or T.TAB_INDENT We will use
# T.EOF to represent undetected indent type.
#
# Tab indent level only increments by 1. Valid space indent is the multiple of
# _indent_level: current_indent = _indent_level * _indent_space_count
#
# Mixing indentation types in front of a stmt is a parser error.
var _indent_level = 0
# The current indent level. Every statement of a block should have the same
# indentation.
var _indent_space_count = -1
# The detected amount of space characters that define an indent.  This count is
# enforced as the indentation for every subsequent space indents.
#
# -1 means space count has not been detected yet.


func parse() -> void:
	_pre_parse()
	_root = _rakuscript()

func _pre_parse() -> void:
	reporter.interview(source)
	_lexer.reporter = reporter
	_lexer.source = source
	_lexer.lex()
	_idx = 0
	_indent_detected = T.EOF
	_indent_level = 0
	_had_error = _lexer.had_error()

func get_root():
	return _root

func had_error():
	return _had_error

func _error(msg, token):
	_had_error = true
	if reporter == null:
		return
	reporter.report_token(msg, token)

# ------------------------------------------------------------------------------
#                                  Parser Helpers
# ------------------------------------------------------------------------------


func _consume():
	if not _eof(): _idx += 1

func _advance():
	_consume()
	return _prev()

func _peek():
	return _lexer.tokens[_idx]

func _lookahead(by, for_token_type):
	var look_token = _get_lookahead(by)
	return look_token.type == for_token_type

func _get_lookahead(by):
	var look_idx = _idx + by
	var look_token = T.EOF
	if look_idx < _lexer.tokens.size():
		look_token = _lexer.tokens[look_idx]
	return look_token


func _prev():
	return _lexer.tokens[_idx - 1]

func _check(token_types):
	if typeof(token_types) == TYPE_ARRAY:
		for type in token_types:
			if _peek().type == type:
				return true
		return false
	else:
		return _peek().type == token_types

func _match(token_types=[]):
	if _check(token_types):
		_consume()
		return true
	return false

func _ignore(token_types):
	while _match(token_types):
		pass

func _expect(token_type, msg=''):
	if _check(token_type):
		_consume()
		return true

	var full_msg = 'Unexpected token:\n'
	full_msg += '\tExpected %s\n' % token_type
	full_msg += '\tBut Got %s\n' % _peek()
	if not msg.empty():
		full_msg += '\t' + msg

	_error(full_msg, _peek())

	return false


func _eof():
	return _peek().type == T.EOF


# Grammar Helpers

func _match_commas():
		var comma_count = 0
		while _match(T.COMMA):
			comma_count += 1
		if comma_count > 1:
			_error('Extra comma', _prev())


# ------------------------------------------------------------------------------
#                                   Grammar Rules
# ------------------------------------------------------------------------------


func _rakuscript():
	var root = Ast.RakuScript.new()
	while not _eof():
		root.stmts.append(_stmt())
	return root

func _block():
	var ast = Ast.Block.new()

	# TODO: indentation.
# 	if _match(T.NEWLINE):
# 		_indent_level += 1

# 		_ignore(T.NEWLINE)

# 		if _match(T.TAB_INDENT):
# 			var indent = _prev()
# 			if _indent_detected == T.EOF:
# 				_indent_detected = indent.type
# 			elif _indent_detected != indent.type:
# 				_error('Mixing tab and space indentation', indent)

# 			if indent.literal > _indent_level:
# 				_error('Current indent level does not match scope expected indent level', indent)
# 			elif indent.literal < _indent_level:
# 				_indent_level -= 1
# 				return ast

# 			ast.stmts.append(_stmt())

# 	else:
# 		ast.stmts.append(_stmt())

	return ast


func _stmt():

	if _match(T.COMMENT):
		return Ast.Literal.new(_prev())
	elif _check(T.WHILE):
		return _while()
	elif _check(T.FOR):
		return _for()
	elif _check(T.IF):
		return _if()
	else:
		return _fn_call_stmt()

func _while():
	var _while_token = _advance()

	var ast = Ast.While.new()
	ast.expr = _logic_expr()

	_expect(T.COLON)

	ast.block = _block()
	return ast


func _for():
	var _for_token = _advance()

	var ast = Ast.For.new()

	if _expect(T.IDENTIFIER):
		ast.ident = _prev()
	else:
		ast.ident = Token.new(T.IDENTIFIER, 0,0,0,0,0,0, null)

	ast.expr = _expr()
	_expect(T.COLON)
	ast.block = _block()

	return ast

func _if():
	var _if_token = _advance()

	var ast = Ast.If.new()
	ast.expr = _logic_expr()
	_expect(T.COLON)
	ast.block = _block()
	if _check(T.ELIF):
		ast.elif_ = _elif()
	if _check(T.ELSE):
		ast.else_ = _else()

	return ast

func _elif():
	var _elif_token = _advance()

	var ast = Ast.ElseIf.new()
	ast.expr = _logic_expr()
	_expect(T.COLON)
	ast.block = _block()
	if _check(T.ELIF):
		ast.else_if = _elif()

	return ast

func _else():
	var _else_token = _advance()

	var ast = Ast.Else.new()
	_expect(T.COLON)
	ast.block = _block()

	return ast

func _fn_call_stmt():
	var ast = Ast.FnCallStmt.new()
	ast.expr = _attr()

	var matched_paren = _match(T.PAREN_OPEN)
	while not _eof():
		if _check(T.PAREN_CLOSE):
			break
		if _check([
		T.STRING_CONTENT,
		T.INTEGER,
		T.FLOAT,
		T.IDENTIFIER,
		T.BRACK_OPEN,
		T.CURLY_OPEN,
		T.PAREN_OPEN,
		]):
			ast.args.append(_fn_arg())
		else:
			break
	if matched_paren:
		_expect(T.PAREN_CLOSE)
	else:
		ast.args += _fn_args_block()

	return ast

func _fn_args_block():
	# FIXME
	var args = []
	while _check(T.NEWLINE):
		if (_lookahead(1, T.TAB_INDENT) or
		   _lookahead(1, T.SPACE_INDENT)):
			var indent = _get_lookahead(1)
			if indent.literal == _indent_level + 1:
				# We have a valid block
				# consume newline
				_consume()
				# consume indent
				_consume()
				while true:
					var arg = _fn_arg()
					if arg:
						args.append(arg)
					else:
						break
			else:
				break
		else:
			break
	return args

func _fn_arg():
	var expr = _expr()
	_match_commas()
	return expr

func _expr():
	return _logic_expr()

func _logic_expr():
	return _logic_or()

func _logic_or():
	var ast = _logic_and()
	while _match(T.OR):
		var op = _prev()
		ast = Ast.Binary.new(
			ast,
			op,
			_logic_and()
		)
	return ast


func _logic_and():
	var ast = _logic_not()
	while _match(T.AND):
		var op = _prev()
		ast = Ast.Binary.new(
			ast,
			op,
			_logic_not()
		)
	return ast

func _logic_not():
	if _match(T.NOT):
		var op = _prev()
		return Ast.Unary.new(
			op,
			_logic_not()
		)
	return _cmp()

func _cmp():
	var ast = _math_expr()
	while _match([
		T.EQUAL_EQUAL,
		T.GREATER_THAN,
		T.GREATER_THAN_EQUAL,
		T.LESS_THAN,
		T.LESS_THAN_EQUAL,
		T.NOT_EQUAL
		]):
		var op = _prev()
		ast = Ast.Binary.new(
			ast,
			op,
			_math_expr()
		)
	return ast

func _math_expr():
	var ast = _math_term()
	while _match([T.PLUS, T.MINUS]):
		var op = _prev()
		ast = Ast.Binary.new(
			ast,
			op,
			_math_term()
		)
	return ast

func _math_term():
	var ast = _math_factor()
	while _match([T.STAR, T.SLASH, T.PERCENT]):
		var op = _prev()
		ast = Ast.Binary.new(
			ast,
			op,
			_math_factor()
		)
	return ast

func _math_factor():
	if _match([T.PLUS, T.MINUS]):
		var op = _prev()
		return Ast.Unary.new(op, _math_factor())
	return _fn_call()

func _fn_call():
	var ast = _attr()
	if _match(T.PAREN_OPEN):
		var fn_call_token = _prev()
		ast = Ast.FnCallExpr.new(ast)
		while not _match(T.PAREN_CLOSE):
			if _eof():
				_error('Unclosed function call.', fn_call_token)
				break
			ast.args.append(_expr())
			_match_commas()
	return ast

func _attr():
	var ast = _subscript()
	var idents = []
	while _match(T.DOT):
		idents.append(_ident())
	if idents.empty():
		return ast
	else:
		return Ast.Attr.new(ast, idents)

func _subscript():
	var ast = _primary()
	if _match(T.BRACK_OPEN):
		ast = Ast.Subscript.new(ast, _expr())
		_expect(T.BRACK_CLOSE)
	return ast

func _primary():
	var ast
	if _match([T.TRUE, T.FALSE, T.NULL, T.STRING_CONTENT, T.INTEGER,
	T.FLOAT, T.IDENTIFIER]):
		ast = Ast.Literal.new()
		ast.token = _prev()
	elif _check(T.BRACK_OPEN):
		ast = _list()
	elif _check(T.CURLY_OPEN):
		ast = _dict()
	elif _check(T.PAREN_OPEN):
		ast = _group()
	else:
		_error('Unknown primary', _peek())

	return ast

func _group():
	_expect(T.PAREN_OPEN)
	_ignore([T.NEWLINE, T.TAB_INDENT, T.SPACE_INDENT])
	var ast = Ast.Group.new()
	ast.expr = _expr()
	_expect(T.PAREN_CLOSE)
	return ast


func _list():
	_expect(T.BRACK_OPEN)
	_ignore([T.NEWLINE, T.TAB_INDENT, T.SPACE_INDENT])
	var ast = Ast.List.new()
	var next = _expr()
	while next:
		ast.exprs.append(next)
		_ignore([T.NEWLINE, T.TAB_INDENT, T.SPACE_INDENT])
		_match_commas()
		if _check(T.BRACK_CLOSE):
			break
		next = _expr()

	_expect(T.BRACK_CLOSE)
	return ast

func _dict():
	_expect(T.CURLY_OPEN)
	_ignore([T.NEWLINE, T.TAB_INDENT, T.SPACE_INDENT])
	var ast = Ast.Dict.new()
	var next = _dict_item()
	while next:
		ast.items.append(next)
		_ignore([T.NEWLINE, T.TAB_INDENT, T.SPACE_INDENT])
		_match_commas()
		next = _dict_item()

	_ignore([T.NEWLINE, T.TAB_INDENT, T.SPACE_INDENT])
	_expect(T.CURLY_CLOSE)
	return ast

func _dict_item():
	var ast = Ast.DictItem.new()
	ast.left = _expr()
	if _match(T.COLON):
		ast.assigns = false
	else:
		_expect(T.EQUAL)
	if (ast.assigns and not
	   (ast.left is Ast.Literal and
		ast.left.token == T.IDENTIFIER)):
		_error('Left hand of dict item assignment should be an identifier', _prev())
	ast.right = _expr()
	return ast

func _str():
	var ast = Ast.Literal.new()
	ast.token = _prev()
	return ast

func _ident():
	if _expect(T.IDENTIFIER):
		var ast = Ast.Literal.new()
		ast.token = _prev()
		return ast

	# TODO: What happens here?
	return null
