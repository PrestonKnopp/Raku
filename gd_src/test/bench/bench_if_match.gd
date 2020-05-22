tool
extends SceneTree

# Result: if branches are 2.4 times faster than match branches

var m = 'a'

func p(s):
	pass

func _initialize():
	var start
	var end
	start = OS.get_system_time_msecs()
	test_match()
	end = OS.get_system_time_msecs()
	print(str('Match Time: ', end - start))

	start = OS.get_system_time_msecs()
	test_if()
	end = OS.get_system_time_msecs()
	print(str('If Time: ', end - start))
	quit()

var iter: int = 1000000

func test_match():
	for i in iter:
		match m:
			'b':p(m)
			'c':p(m)
			'd':p(m)
			1:p(m)
			2:p(m)
			3:p(m)
			4:p(m)
			'a':p(m)

func test_if():
	for i in iter:
		if 'b' == m: p('b')
		elif 'c' == m: p('c')
		elif 'd' == m: p('d')
		elif '1' == m: p(1)
		elif '2' == m: p(2)
		elif '3' == m: p(3)
		elif '4' == m: p(4)
		elif 'a' == m: p('a')
