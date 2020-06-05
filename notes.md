# TOC

<!-- TOC -->

- [Raku Notes](#raku-notes)
  - [Keywords](#keywords)
  - [Commas](#commas)
  - [Accessing GDScript](#accessing-gdscript)
  - [Strings](#strings)
  - [String Interpolation](#string-interpolation)
  - [Function Syntax](#function-syntax)
    - [`define` Function Example](#define-function-example)
    - [Symbol](#symbol)
  - [Signals](#signals)

<!-- /TOC -->

# Raku Notes

- Dictionary field syntax should match GDScript
  - Map symbol to value. `key = value` == `dict["key"] = value`
  - Map expr result to value. `key: value` == `dict[key] = value`

## Keywords

```
true false and or not
pass end
if elif else
while for in
func var const
menu
gd
```

## Operators

```
== != < <= > >=
- + * / %
```

## Commas

Commas are optional for arrays, dictionaries, arguments, and parameters. They
can be interspersed between elements.

```
[1 2 3 4 5]
{a = 1 b = 2 c = 3}
func hello(one two three)
hello one two three
hello(one two three)
hello one1 one2, two1 two2
```

When commas are present they are not ignored. The following is invalid:

```
[ 1 2 , , 4 5]
        ^ error: Expected expression following comma.
```

However, an extra comma at the end of a list is allowed:

```
[1 2 , 4 5 ,]
[
	1,
	2,
	4,
	5,
]
```

## Accessing GDScript

Access gdscript directly with `gd:`.

`gd:` can be used

- linewise `gd: your gdscript until a new line`
- blockwise

```
gd:
	your gdscript block
	your gdscript block
```

The following are valid examples:

```
define node = gd: Node.new()

define
	a = gd: Vector2()
	b = gd: Sprite.new()
	c = gd: "hello".plus_file("world")

gd:
	class MyClass:
		var a = 1
		var b = 2
		func _init(): print("Hello")
```

Which expand to:

```
Rakugo.define("node", Node.new())

Rakugo.define("a", Vector2())
Rakugo.define("b", Sprite.new())
Rakugo.define("c", "hello".plus_file("world"))

class MyClass:
	var a = 1
	var b = 2
	func _init(): print("Hello")
```

The following are valid examples, but will result in a GDScript parser error.

```
define rakugo_var = gd: class Hello: extends Hello
```

Which expand to:

```
Rakugo.define("rakugo_var", class Hello: extends Hello)
```

## Strings

All strings are multi-line strings. The rules for strings are:

1. If the last line of a multi-line string is a closing quote, the previous `\n`
   will be ignored.
1. If the first line of a multi-line string is only whitespace, it will be
   ignored.

```
"
  hello
"

"

  Hello

"
```

The above equal:

```
"  hello"
"{/nl}  hello{/nl}"
```

2. Identation from the containing scope of the String is not included.

```
dialog name:
...."
....    hello
...."
```

The indentation shown as `.` will not be in the String. The String literal will
be:

```
"    hello"
```


## String Interpolation

TODO

## Function Syntax

```
func example(%sym pos1 pos2 {named1 named2 ...rest_named} ...rest_pos):
	print "Symbol [sym]"
	print "Positional Args [pos1] [pos2]"
	print "Named Args [named1] [named2]"
	for pos in rest_pos:
		print "Rest Pos [pos]"
	for key in rest_named:
		print "Rest Named [key]: [rest_named[key]]"
```

A function call **statement** can be called **without parentheses**.
Function arguments can be separated by spaces and specified on multiple lines
with indentation. Function call **expressions** must use parentheses.

```
example MySymbol "one" 2
	named1="none"
	named2=3
	4 5
	r=100 g=200 b=100

# parentheses are required for other_func()
take_result other_func()
```

Commas are optional and can be interspersed between arguments.

```
example(MySymbol "one" 2, named1 = "none" named2 = 3, 4 5, r=100 g=200 b=100)
```

The two `example` calls print:

```
Symbol MySymbol
Positional Args one 2
Named Args none 3
Rest Pos 4
Rest Pos 5
Rest Named r: 100
Rest Named g: 200
Rest Named b: 100
```

### `define` Function Example

```
func define({...rest_named}):
	for key in rest_named:
		gd: Rakugo.define(key, rest_named[key])
```

### Symbol

`%symbol`

This tells the parser to not evaluate the expression argument, but to pass it
as a string literal to the calling function.

```
func take_symbol(%symbol):
	print symbol

take_symbol hello # prints hello
take_symbol okay.there # prints okay.there
take_symbol "hello" # prints "hello"
take_symbol get_node("hello") # prints get_node("hello")
```

Examples:

1. The jump function

```
func jump(%to_dialog):
	gd: Rakugo.jump(to_dialog)

jump Minigame
jump Scene_id/Node_name/dialog_name
```

2. The show function

```
func show(%...parts):
	gd:
		if parts.size() > 0:
			Rakugo.show(parts.join(' '))

show eva smile
show bg lecturehall
```

## Signals

Signals are declared exactly like they are in GDScript.

```
signal my_signal(one, two)
```

But connecting signals has some sugar on top.

```
@my_signal
func on_my_signal(one, two):
	pass
```

The above would expand to

```
signal my_signal(one, two)

func _init():
	connect('my_signal', self, 'on_my_signal')

func on_my_signal(one, two):
	pass
```
