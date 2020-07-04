
# ------------------------------------------------------------------------------
#                               Generated Code Below
# ------------------------------------------------------------------------------
#
# See tools/generate_ast_classes.gd.

class Ast:
	extends Reference


class Expr:
	extends Ast


class Stmt:
	extends Ast


class Literal extends Expr:
	var token = null
	func _init(p_token=null):
		token = p_token
	func accept(visitor):
		return visitor.visitLiteral(self)


class Unary extends Expr:
	var op = null
	var right = null
	func _init(p_op=null,p_right=null):
		op = p_op
		right = p_right
	func accept(visitor):
		return visitor.visitUnary(self)


class Binary extends Expr:
	var left = null
	var op = null
	var right = null
	func _init(p_left=null,p_op=null,p_right=null):
		left = p_left
		op = p_op
		right = p_right
	func accept(visitor):
		return visitor.visitBinary(self)


class List extends Expr:
	var exprs = []
	func _init(p_exprs=null):
		if p_exprs != null: exprs = p_exprs
	func accept(visitor):
		return visitor.visitList(self)


class Dict extends Expr:
	var items = []
	func _init(p_items=null):
		if p_items != null: items = p_items
	func accept(visitor):
		return visitor.visitDict(self)


class DictItem extends Expr:
	var left = null
	var right = null
	func _init(p_left=null,p_right=null):
		left = p_left
		right = p_right
	func accept(visitor):
		return visitor.visitDictItem(self)


class Block extends Ast:
	var stmts = []
	func _init(p_stmts=null):
		if p_stmts != null: stmts = p_stmts
	func accept(visitor):
		return visitor.visitBlock(self)


class While extends Stmt:
	var expr = null
	var block = null
	func _init(p_expr=null,p_block=null):
		expr = p_expr
		block = p_block
	func accept(visitor):
		return visitor.visitWhile(self)


class For extends Stmt:
	var ident = null
	var expr = null
	var block = null
	func _init(p_ident=null,p_expr=null,p_block=null):
		ident = p_ident
		expr = p_expr
		block = p_block
	func accept(visitor):
		return visitor.visitFor(self)


class If extends Stmt:
	var expr = null
	var block = null
	var else_if = null
	var else_ = null
	func _init(p_expr=null,p_block=null,p_else_if=null,p_else_=null):
		expr = p_expr
		block = p_block
		else_if = p_else_if
		else_ = p_else_
	func accept(visitor):
		return visitor.visitIf(self)


class ElseIf extends Stmt:
	var expr = null
	var block = null
	var else_if = null
	func _init(p_expr=null,p_block=null,p_else_if=null):
		expr = p_expr
		block = p_block
		else_if = p_else_if
	func accept(visitor):
		return visitor.visitElseIf(self)


class Else extends Stmt:
	var block = null
	func _init(p_block=null):
		block = p_block
	func accept(visitor):
		return visitor.visitElse(self)


class Gd extends Stmt:
	var block = null
	func _init(p_block=null):
		block = p_block
	func accept(visitor):
		return visitor.visitGd(self)

