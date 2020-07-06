extends Reference

var _messages = []
var _source = ''

func interview(source: String):
	_source = source

func report(message, start_idx, end_idx, line, column):
	var format = 'Error: %s on line %s column %s <%s>'
	var args = [message, line, column, _source.substr(start_idx, end_idx - start_idx)]
	_messages.append(format % args)

func report_token(message, token):
	var format = 'Error: %s with token %s <%s>'
	var args = [message, token,
		_source.substr(token.start, token.end - token.start)]
	_messages.append(format % args)

func publish():
	for message in _messages:
		print(message)
