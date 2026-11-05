class_name RuleIcon
extends Control
## Small looping pixel animation that illustrates one rule, so the
## instructions are visual and work with sound off (report SP03).
## kind: "pass", "trivia", "lives", "minigame", "win"

@export var kind := "pass"
@export var px := 4   # size of one "pixel"


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(30 * px, 18 * px)


func _process(_delta: float) -> void:
	queue_redraw()


func _p(x: float, y: float, w: float, h: float, c: Color) -> void:
	var o := (size - Vector2(30 * px, 18 * px)) / 2.0
	draw_rect(Rect2(o + Vector2(x, y) * px, Vector2(w, h) * px), c)


func _draw() -> void:
	var t := 1.5 if GameSettings.reduce_motion else Time.get_ticks_msec() / 1000.0
	match kind:
		"pass": _draw_pass(t)
		"trivia": _draw_trivia(t)
		"lives": _draw_lives(t)
		"minigame": _draw_minigame(t)
		"win": _draw_win(t)


func _draw_phone(x: float, y: float, screen: Color) -> void:
	_p(x, y, 6, 10, Color("#c9c2e0"))
	_p(x + 1, y + 1, 4, 7, screen)
	_p(x + 2, y + 8.5, 2, 0.5, Color("#6b5f94"))


func _draw_pass(t: float) -> void:
	# two players; phone slides from one to the other
	var colors := [UIStyle.ORANGE, UIStyle.CYAN]
	for i in 2:
		var x := 2 + i * 22
		_p(x + 1, 3, 4, 4, colors[i])            # head
		_p(x, 8, 6, 8, colors[i].darkened(0.3))  # body
	var k := (sin(t * 1.8) + 1.0) / 2.0
	var phone_x := lerpf(8, 16, smoothstep(0.0, 1.0, k))
	_draw_phone(phone_x, 6, colors[0] if k < 0.5 else colors[1])


func _draw_trivia(t: float) -> void:
	var pick := int(t * 1.2) % 4
	for i in 4:
		var c := Color("#3b2a6e")
		if i == 2 and pick >= 2:
			c = UIStyle.GREEN
		elif i == pick:
			c = UIStyle.PURPLE
		_p(4, 1 + i * 4.2, 22, 3.2, c)
		_p(5, 2 + i * 4.2, 2, 1.2, UIStyle.TEXT)
	if pick >= 2:
		_p(27, 9, 2, 1, UIStyle.GOLD)   # little "+" sparkle
		_p(27.5, 8.5, 1, 2, UIStyle.GOLD)


func _draw_lives(t: float) -> void:
	var shape := LivesDisplay.SHAPE
	var lost := int(t * 1.0) % 3 == 2
	for h in 3:
		var c := UIStyle.RED
		if h == 2 and lost:
			c = Color("#3b2a5e")
		for y in shape.size():
			for x in shape[y].length():
				if shape[y][x] == "X":
					_p(3 + h * 8.5 + x, 5 + y, 1, 1, c)


func _draw_minigame(t: float) -> void:
	# 3x3 memory grid with tiles lighting up
	var lit: Array[int] = [0, 4, 6, 8]
	var step := int(t * 2.0) % 6
	for i in 9:
		var on: bool = step < 4 and lit[step] == i
		var c := UIStyle.CYAN if on else Color("#3b2a6e")
		_p(9 + (i % 3) * 4.2, 1 + floorf(i / 3.0) * 5.4, 3.4, 4.6, c)


func _draw_win(t: float) -> void:
	var bob := roundf(sin(t * 2.0) * 1.0)
	# trophy
	_p(11, 2 + bob, 8, 6, UIStyle.GOLD)
	_p(9, 3 + bob, 2, 3, UIStyle.GOLD)
	_p(19, 3 + bob, 2, 3, UIStyle.GOLD)
	_p(13, 8 + bob, 4, 3, UIStyle.GOLD.darkened(0.2))
	_p(11, 11 + bob, 8, 2, UIStyle.GOLD.darkened(0.35))
	_p(12, 3 + bob, 2, 2, Color(1, 1, 1, 0.7))
	# sparkles
	for i in 3:
		var on: bool = int(t * 3.0 + i) % 3 == 0
		if on:
			var sx: float = [4.0, 24.0, 26.0][i]
			var sy: float = [3.0, 1.0, 10.0][i]
			_p(sx, sy - 1, 1, 3, UIStyle.TEXT)
			_p(sx - 1, sy, 3, 1, UIStyle.TEXT)
