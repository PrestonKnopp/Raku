extends SceneTree

const Lexer = preload('res://raku_lexer.gd')

class Reporter:
	func interview(st):
		pass
	func report(message, start_idx, end_idx, line, column):
		pass

func _initialize():
	var lexer = Lexer.new()
	lexer.source = '\\/(){}+-*:\n=><|#comment here\n()'
	lexer.reporter = Reporter.new()
	lexer.reporter.interview(lexer.source)
	lexer.lex()
	for token in lexer.tokens:
		printt(token, lexer.source.substr(token.start, token.end - token.start))
	quit()
