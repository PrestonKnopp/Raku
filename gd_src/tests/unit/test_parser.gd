extends "res://addons/gut/test.gd"

const Reporter = preload('res://reporter.gd')

class GutReporter extends Reporter:
	var gut
	func _init(p_gut): gut = p_gut
	func publish():
		for msg in _messages: gut.p(msg)


var Parser = load('res://raku_parser.gd')
var Visitors = load('res://raku_ast_visitors.gd')

var parser

func assert_tree(source, expected):
	parser.source = source
	parser.parse()
	var tree = parser.get_root()
	assert_not_null(tree)
	if not tree:
		return
	var got = tree.accept(Visitors.FuncStyleFormatter.new())
	expected = str('rakuscript(', expected, ')')
	gut.p(str(source, ' -> ', got, ' :: ', expected))
	assert_eq(got, expected)
	assert_false(parser.had_error(), 'Parser had errors.')
	parser.reporter.publish()

func assert_trees(list):
	assert_true(list.size() % 2 == 0)
	for i in range(0, list.size(), 2):
		var source = list[i]
		var expected = list[i + 1]
		assert_tree(source, expected)

func before_each():
	parser = Parser.new()
	parser.reporter = GutReporter.new(gut)

func after_each():
	pass

func test_parser():
	assert_trees([
		'hello(1 + 1)', 'call(hello plus(1 1))',
		'a("hi")', 'call(a "hi")',
		'a([1, 2])', 'call(a list(1 2))',
		'a([1 2])', 'call(a list(1 2))',
		'a(a(1))', 'call(a call(a 1))',
		'a a(1)', 'call(a call(a 1))',
	])

func test_comment():
	assert_trees([
		"#a", "comment",
		"#a\nfn()", "#a call(fn)",
	])

func test_math_expr():
	assert_trees([
	"1 + 1", "plus(1 1)",
	])

func test_func_call_stmt():
	assert_trees([
	"fn()", "call(fn)",
	"fn('a')", 'call("a")',
	"fn('a' 'b')", 'call("a" "b")',
	"fn('a','b')", 'call("a" "b")',
	"fn 'a'", 'call("a")',
	"fn 'a' 'b'", 'call("a" "b")',
	"fn 'a','b'", 'call("a" "b")',
	])

func test_control_flow():
	assert_trees([
	"while true:\n\tpass",
	"while(true block(pass))",

	"for i in 1:\n\tpass",
	"for(ident 1 block(pass))",

	"if true:\n\tpass",
	"if(true block(pass))",

	"if true:\n\tpass\nelse:\n\tpass",
	"if(true block(pass) else(block(pass)))",

	"if true:\n\tpass\nelif false:\n\tpass\nelse:\n\tpass",
	"if(true block(pass) elif(false block(pass)) else(block(pass)))",
	])
