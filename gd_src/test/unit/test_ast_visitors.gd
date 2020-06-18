# test_visitors.gd
extends "res://addons/gut/test.gd"


var Tree = load('res://raku_ast.gd')
var Visitors = load('res://raku_ast_visitors.gd')
var Token = load('res://raku_token.gd')

func test_func_style_printer():
	# 10 + 10 + -10
	var tree = Tree.Binary.new(
		Tree.Binary.new(
			Tree.Literal.new(Token.new(0,0,0,0,0,0,0, 10)),
			'+',
			Tree.Literal.new(Token.new(0,0,0,0,0,0,0, 10))
		),
		'+',
		Tree.Unary.new(
			'-',
			Tree.Literal.new(Token.new(0,0,0,0,0,0,0, 10))
		)
	)

	print(Visitors.FuncStyleFormatter.new().visit(tree))
