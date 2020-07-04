# generate_ast_classes.gd
# -----------------------
#
# Generate ast from project root with the command:
#
#    /path/to/godot/binary -s tools/generate_ast_classes.gd
#
tool
extends SceneTree

var b = PoolStringArray([])

func _init():

	b.append("""
# ------------------------------------------------------------------------------
#                               Generated Code Below
# ------------------------------------------------------------------------------
#
# See tools/generate_ast_classes.gd.
""")
	clazz('Ast', 'Reference')
	clazz('Expr', 'Ast')
	clazz('Stmt', 'Ast')

	mk_all("""Literal:Expr:token
Unary:Expr:op,right
Binary:Expr:left,op,right
List:Expr:exprs=[]
Dict:Expr:items=[]
DictItem:Expr:left,right
Block:Ast:stmts=[]
While:Stmt:expr,block
For:Stmt:ident,expr,block
If:Stmt:expr,block,else_if,else_
ElseIf:Stmt:expr,block,else_if
Else:Stmt:block
Gd:Stmt:block""")

	var f = File.new()
	var err = f.open('raku_ast.gd', f.WRITE)
	if err != OK:
		print('Error<%s> opening raku_ast.gd for writing.' % err)
	else:
		f.store_string(b.join('\n'))
		f.close()
	quit()


# Wrapper to gen a class. When block is an empty array extend will be placed as
# a statement within the class block.
func clazz(name, extend, block=[]):
	var cls = 'class %s' % name
	if extend != null:
		if block.size() > 0:
			cls += ' extends %s:' % extend
		else:
			cls += ':\n'
			cls += '\textends %s' % extend
	else:
		cls += ':'
	b.append(cls)

	for part in block:
		b.append('\t' + part)

	b.append('\n')


# props_str: 'var_name=12,other="default_val"'
# p_name: 'MyClass'
# extend: 'Expr'
func mk(p_name, extend, props_str):
	var props = props_str.split(',')

	var block = PoolStringArray([])

	var fn_init_params = PoolStringArray([])
	var fn_init_block = PoolStringArray([])
	for prop in props:
		var prop_parts = prop.split('=')
		var name = prop_parts[0]
		var value = 'null'
		if prop_parts.size() > 1:
			value = prop_parts[1]
		block.append('var %s = %s' % [name, value])
		fn_init_params.append('p_%s=null' % name)
		if value == 'null':
			fn_init_block.append('\t%s = p_%s' % [name, name])
		else:
			fn_init_block.append('\tif p_%s != null: %s = p_%s' % [name, name, name])
	

	block.append('func _init(%s):' % fn_init_params.join(','))
	block.append_array(fn_init_block)


	block.append('func accept(visitor):')
	block.append('\treturn visitor.visit%s(self)' % p_name)


	clazz(p_name, extend, block)

# section: ClassName:ExtendName:prop1,prop2=def_val,prop3
func mk_all(text):
	var sections = text.split('\n')
	for section in sections:
		var section_parts = section.split(':')
		if section_parts.size() != 3:
			print(section_parts)
		mk(section_parts[0], section_parts[1], section_parts[2])
