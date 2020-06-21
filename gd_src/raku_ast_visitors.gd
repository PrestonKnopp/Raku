# raku_ast_visitors.gd
# --------------------

class Visitor:
	var Ast = load('res://raku_ast.gd')
	var Token = load('res://raku_token.gd')
	func visit(ast):
		var s = self
		if ast is Ast.Literal:
			return s.visitLiteral(ast)
		elif ast is Ast.Unary:
			return s.visitUnary(ast)
		elif ast is Ast.Binary:
			return s.visitBinary(ast)
		elif ast is Token:
			return s.visitToken(ast)
		else:
			return ast

class FuncStyleFormatter extends Visitor:

	func funcify(caller, args=[]):
		var s = str(visit(caller))
		if args.size() > 0:
			s += '('
			var arg_strs = PoolStringArray([])
			arg_strs.resize(args.size())
			for i in args.size():
				arg_strs[i] = visit(args[i])
			s += arg_strs.join(' ')
			s += ')'
		return s

	func visitLiteral(e):
		return str(e.token.literal)

	func visitUnary(e):
		return funcify(e.op, [e.right])
	
	func visitBinary(e):
		return funcify(e.op, [e.left, e.right])

	func visitToken(e):
		return e.get_type_name().to_lower()
