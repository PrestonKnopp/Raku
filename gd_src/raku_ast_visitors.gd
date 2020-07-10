# raku_ast_visitors.gd
# --------------------

class Visitor:
	extends Reference


class FuncStyleFormatter extends Visitor:

	func funcify(caller, args=[]):
		var s = str(caller)
		if args.size() > 0:
			s += '('
			var arg_strs = PoolStringArray([])
			arg_strs.resize(args.size())
			for i in args.size():
				arg_strs[i] = args[i].accept(self)
			s += arg_strs.join(' ')
			s += ')'
		return s

	func visitRakuScript(e):
		return funcify('rakuscript', e.stmts)

	func visitFnCallStmt(e):
		return funcify('call', [e.expr] + e.args)

	func visitFnCallExpr(e):
		return visitFnCallStmt(e)

	func visitList(e):
		return funcify('list', e.exprs)

	func visitLiteral(e):
		if e.token.type == e.token.Type.STRING_CONTENT:
			return '"%s"' % e.token.literal
		return str(e.token.literal)

	func visitUnary(e):
		return funcify(e.op.get_type_name().to_lower(), [e.right])

	func visitBinary(e):
		return funcify(e.op.get_type_name().to_lower(), [e.left, e.right])
