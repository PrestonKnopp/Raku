extends SceneTree

const Lexer = preload('res://raku_lexer.gd')

class Reporter:
	var messages = []
	var s
	func interview(st): s = st
	func report(message, start_idx, end_idx, line, column):
		messages.append('Error: %s on line %s column %s - %s' % [message, line, column, s.substr(start_idx, end_idx)])
	func publish():
		for message in messages:
			print(message)

func _initialize():
	var lexer = Lexer.new()
	lexer.source = '\\/(){}+-*:\n=><#comment here\n("hello world\n are you")'
	lexer.reporter = Reporter.new()
	lexer.reporter.interview(lexer.source)
	lexer.lex()
	for token in lexer.tokens:
		printt(token, lexer.source.substr(token.start, token.end - token.start))
	lexer.reporter.publish()
	quit()
