# raku_ast.gd
# -----------

class Ast:
	extends Reference


class Expr:
	extends Ast

class Literal extends Expr:
	var token
	func _init(t):
		token = t

class Unary extends Expr:
	var op
	var right
	func _init(o,r):
		op = o
		right = r

class Binary extends Expr:
	var left
	var op
	var right
	func _init(l,o,r):
		left = l
		op = o
		right = r

class List extends Expr:
	var exprs
	func _init(e=[]):
		exprs = e

class Dict extends Expr:
	var items
	func _init(i=[]):
		items = i

class DictItem extends Expr:
	var left
	var right
	func _init(l,r):
		left = l
		right = r


class Block extends Ast:
	var stmts
	func _init(s):
		stmts = s

class Stmt:
	extends Ast

class While extends Stmt:
	var expr
	var block
	func _init(e,b):
		expr = e
		block = b

class For extends Stmt:
	var ident
	var expr
	var block
	func _init(i,e,b):
		ident = i
		expr = e
		block = b

class If extends Stmt:
	var expr
	var block
	var else_if
	var else_
	func _init(e,b,ei,e_):
		expr = e
		block = b
		else_if = ei
		else_ = e_

class ElseIf:
	extends If

class Else extends Stmt:
	var block
	func _init(b):
		block = b

class Gd extends Stmt:
	var block
	func _init(b):
		block = b
