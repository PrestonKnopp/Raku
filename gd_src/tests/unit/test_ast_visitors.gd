# test_visitors.gd
extends "res://addons/gut/test.gd"


var Ast = load('res://raku_ast.gd')
var Visitors = load('res://raku_ast_visitors.gd')
var Token = load('res://raku_token.gd')


func t(token_type, literal=null):
	return Token.new(token_type, 0,0,0,0,0,0, literal)


func test_func_style_printer():
	# 10 + 10 + -10
	var tree = Ast.Binary.new(
		Ast.Binary.new(
			Ast.Literal.new(t(0, 10)),
			t(Token.Type.PLUS),
			Ast.Literal.new(t(0, 10))
		),
		t(Token.Type.PLUS),
		Ast.Unary.new(
			t(Token.Type.MINUS),
			Ast.Literal.new(t(0, 10))
		)
	)

	print(tree.accept(Visitors.FuncStyleFormatter.new()))
