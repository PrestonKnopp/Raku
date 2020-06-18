# raku_ast_visitors.gd
# ---------------------------

class Visitor:
	var Tree = load('res://raku_ast.gd')
	func visit(ast):
		var s = self
		if ast is Tree.Literal:
			return s.visitLiteral(ast)
		elif ast is Tree.Unary:
			return s.visitUnary(ast)
		elif ast is Tree.Binary:
			return s.visitBinary(ast)
		else:
			return str(ast)

class FuncStyleFormatter extends Visitor:

	func funcify(caller, args=[]):
		var s = '' + str(caller)
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
