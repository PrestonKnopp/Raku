extends "res://addons/gut/test.gd"

const Lexer = preload('res://raku_lexer.gd')
const Reporter = preload('res://reporter.gd')

const T = Lexer.Token.Type

var lexer
var reporter

func t(t: int, sl: int, sc: int, el: int, ec: int, s: int, e: int, l=null):
	return Lexer.Token.new(t, sl, sc, el, ec, s, e, l)

func assert_tokens(source: String, expected_tokens: Array) -> void:
	lexer = Lexer.new()
	lexer.source = source
	lexer.reporter = Reporter.new()
	lexer.reporter.interview(lexer.source)
	lexer.lex()

	assert_eq(lexer.tokens.size(), expected_tokens.size() + 1)

	for i in expected_tokens.size():
		var got = lexer.tokens[i]
		var expected = expected_tokens[i]
		assert_eq(str(got), str(expected))
	
	var last_token = expected_tokens[expected_tokens.size() - 1]
	var expected_eof = last_token
	if expected_eof.type != T.EOF:
		expected_eof = t(
			T.EOF,
			lexer._line, lexer._column,
			lexer._line, lexer._column,
			lexer._idx, lexer._idx
		)

	var got_eof = lexer.tokens[lexer.tokens.size() - 1]
	assert_eq(str(got_eof), str(expected_eof))

func zip_assert_tokens(sources: Array, expected_tokens: Array) -> void:
	assert_eq(sources.size(), expected_tokens.size(),
		"Different amount of sources and tokens.")
	

	for i in sources.size():
		var source = sources[i]
		var token = expected_tokens[i]
		assert_tokens(source, [token])

func test_lex_single_character_tokens():
	assert_tokens(
		'\\/(){}[]+-*:=<>!',
		[
			t(T.BACK_SLASH, 0,0, 0,1, 0,1),
			t(T.SLASH, 0,1, 0,2, 1,2),
			t(T.PAREN_OPEN, 0,2, 0,3, 2,3),
			t(T.PAREN_CLOSE, 0,3, 0,4, 3,4),
			t(T.CURLY_OPEN, 0,4, 0,5, 4,5),
			t(T.CURLY_CLOSE, 0,5, 0,6, 5,6),
			t(T.BRACK_OPEN, 0,6, 0,7, 6,7),
			t(T.BRACK_CLOSE, 0,7, 0,8, 7,8),
			t(T.PLUS, 0,8, 0,9, 8,9),
			t(T.MINUS, 0,9, 0,10, 9,10),
			t(T.STAR, 0,10, 0,11, 10,11),
			t(T.COLON, 0,11, 0,12, 11,12),
			t(T.EQUAL, 0,12, 0,13, 12,13),
			t(T.LESS_THAN, 0,13, 0,14, 13,14),
			t(T.GREATER_THAN, 0,14, 0,15, 14,15),
			t(T.NOT, 0,15, 0,16, 15,16),
		]
	)

func test_lex_group_character_tokens():
	assert_tokens(
		'==>=<=!=&&||',
		[
			t(T.EQUAL_EQUAL, 0,0, 0,2, 0,2),
			t(T.GREATER_THAN_EQUAL, 0,2, 0,4, 2,4),
			t(T.LESS_THAN_EQUAL, 0,4, 0,6, 4,6),
			t(T.NOT_EQUAL, 0,6, 0,8, 6,8),
			t(T.AND, 0,8, 0,10, 8,10),
			t(T.OR, 0,10, 0,12, 10,12),
		]
	)

func test_lex_numbers():
	assert_tokens(
		'123 123.01',
		[
			t(T.INTEGER, 0,0, 0,3, 0,3, 123),
			t(T.FLOAT,   0,4, 0,10, 4,10, float('123.01')),
		]
	)

func test_lex_strings():
	assert_tokens(
		""" "" "hello" '' 'hello'""",
		[
			t(T.STRING_CONTENT, 0,1, 0,3, 1,3, ''),
			t(T.STRING_CONTENT, 0,4, 0,11, 4,11, 'hello'),
			t(T.STRING_CONTENT, 0,12, 0,14, 12,14, ''),
			t(T.STRING_CONTENT, 0,15, 0,22, 15,22, 'hello'),
		]
	)

func test_lex_identifiers():
	zip_assert_tokens(
		'a _b c1 d_2'.split(' '),
		[
			t(T.IDENTIFIER, 0,0, 0,1, 0,1, 'a'),
			t(T.IDENTIFIER, 0,0, 0,2, 0,2, '_b'),
			t(T.IDENTIFIER, 0,0, 0,2, 0,2, 'c1'),
			t(T.IDENTIFIER, 0,0, 0,3, 0,3, 'd_2'),
		]
	)

func test_lex_keywords():
	zip_assert_tokens(
		['if', 'elif', 'else'],
		[
			t(T.IF, 0,0, 0,2, 0,2),
			t(T.ELIF, 0,0, 0,4, 0,4),
			t(T.ELSE, 0,0, 0,4, 0,4),
		]
	)

	zip_assert_tokens(
		['ifelse', 'while1'],
		[
			t(T.IDENTIFIER, 0,0, 0,6, 0,6, 'ifelse'),
			t(T.IDENTIFIER, 0,0, 0,6, 0,6, 'while1'),
		]
	)

func test_lex_newlines():
	assert_tokens(
		'a\nb',
		[
			t(T.IDENTIFIER, 0,0, 0,1, 0,1, 'a'),
			t(T.IDENTIFIER, 1,0, 1,1, 2,3, 'b')
		]
	)

	assert_tokens(
		'"a\nb"',
		[
			t(T.STRING_CONTENT, 0,0, 1,2, 0,5, "a\nb")
		]
	)

func test_lex_indents():
	zip_assert_tokens(
		'\n\t\t%\n..'.replace('.', ' ').split('%'),
		[
			t(T.TAB_INDENT, 1,0, 1,2, 1,3, 2),
			t(T.SPACE_INDENT, 1,0, 1,2, 1,3, 2),
		]
	)

	assert_tokens(
		'\n..\t..'.replace('.', ' '),
		[
			t(T.SPACE_INDENT, 1,0, 1,2, 1,3, 2),
			t(T.TAB_INDENT, 1,2, 1,3, 3,4, 1),
			t(T.SPACE_INDENT, 1,3, 1,5, 4,6, 2),
		]
	)

