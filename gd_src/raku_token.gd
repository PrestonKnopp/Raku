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

	STRING_OPEN, # " | '
	STRING_CLOSE, # " | '
	INTEGER, # 0-9
	FLOAT, # 0-9.0-9

	IDENT, # an identifier
	DEFINE, # define
	IF, # if
	ELIF, # elif
	ELSE, # else
	WHILE, # while
	TRUE, # true
	FALSE, # false

	EOF
}

var type: int
var line: int
var column: int
var start: int
var end: int

var literal

func _init(p_type: int, p_line: int, p_column: int, p_start: int, p_end: int, p_literal):
	type = p_type
	line = p_line
	column = p_column
	start = p_start
	end = p_end
	literal = p_literal

func _to_string() -> String:
	return get_to_string_fmt() % [get_type_name(), line, column, start, end, literal]

func get_to_string_fmt() -> String:
	return '(%s %s:%s, %s-%s, %s)'

func get_type_name() -> String:
	var idx: int = Type.values().find(type)
	if idx == -1:
		return ''
	return Type.keys()[idx]
