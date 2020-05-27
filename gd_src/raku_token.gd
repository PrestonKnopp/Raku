extends Reference

enum Type {
	BACK_SLASH, # \\
	SLASH, # /
	PAREN_OPEN, # (
	PAREN_CLOSE, # )
	CURLY_OPEN, # {
	CURLY_CLOSE, # }
	BRACK_OPEN, # [
	BRACK_CLOSE, # ]
	PLUS, # +
	MINUS, # -
	STAR, # *
	COLON, # :

	EQUAL, # =
	EQUAL_EQUAL, # ==
	GREATER_THAN, # >
	GREATER_THAN_EQUAL, #>=
	LESS_THAN, # <
	LESS_THAN_EQUAL, # <=
	NOT, # ! not
	NOT_EQUAL, # !=

	AND, # and &&
	OR, # or ||

	# a group of ' ' or '\t' after a '\n'
	SPACE_INDENT,
	TAB_INDENT,

	COMMENT, # #...

	# It may be preferable to lex string contents.
	# STRING_OPEN, # " or '
	# STRING_CLOSE, # " or '
	STRING_CONTENT, # "..." or '...'
	INTEGER, # 0-9
	FLOAT, # 0-9.0-9

	IDENTIFIER, # hello_1
	IF, # if
	ELIF, # elif
	ELSE, # else
	WHILE, # while
	FOR, # for
	IN, # in
	TRUE, # true
	FALSE, # false

	EOF
}

var type: int
var start_line: int
var end_line: int
var start_column: int
var end_column: int
var start: int
var end: int

var literal

func _init(p_type: int, p_start_line: int, p_start_column: int, p_end_line: int,
		p_end_column: int, p_start: int, p_end: int, p_literal):
	type = p_type
	start_line = p_start_line
	start_column = p_start_column
	end_line = p_end_line
	end_column = p_end_column
	start = p_start
	end = p_end
	literal = p_literal

func equals(other) -> bool:
	return (
		other is (get_script() as Script) and
		type == other.type and
		start_line == other.start_line and
		end_line == other.end_line and
		start_column == other.start_column and
		end_column == other.end_column and
		start == other.start and
		end == other.end
	)

func _to_string() -> String:
	var format = '(%s %s:%s-%s:%s, %s-%s, %s)'
	return format % [get_type_name(), start_line, start_column, end_line,
			end_column, start, end, literal]

func get_type_name() -> String:
	var idx: int = Type.values().find(type)
	if idx == -1:
		return ''
	return Type.keys()[idx]
