class_name LivesDisplay
extends Control
## Row of pixel hearts. Lost lives turn dark; a lost heart flashes and shrinks,
## a regained heart pops in.

const SHAPE := [
	".XX.XX.",
	"XXXXXXX",
	"XXXXXXX",
	".XXXXX.",
	"..XXX..",
	"...X...",
]

@export var max_lives := 3:
	set(v):
		max_lives = maxi(1, v)
		_update_size()
@export var pixel := 3:
	set(v):
		pixel = maxi(1, v)
		_update_size()
@export var gap := 4
@export var full_color := UIStyle.RED
@export var empty_color := Color("#3b2a5e")

var lives := 3
var _anim_index := -1
var _anim_t := 1.0
var _anim_gain := false


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_update_size()


func set_lives(value: int, animate := true) -> void:
	value = clampi(value, 0, max_lives)
	if animate and value != lives:
		_anim_gain = value > lives
		_anim_index = value - 1 if _anim_gain else value
		_anim_t = 0.0
		var tw := create_tween()
		tw.tween_property(self, "_anim_t", 1.0, 0.6)
		tw.parallel().tween_method(func(_v): queue_redraw(), 0.0, 1.0, 0.6)
	lives = value
	queue_redraw()


func _update_size() -> void:
	var w := max_lives * 7 * pixel + (max_lives - 1) * gap
	custom_minimum_size = Vector2(w, 6 * pixel)
	queue_redraw()


func _draw() -> void:
	var heart_w := 7 * pixel
	for i in max_lives:
		var filled := i < lives
		var color := full_color if filled else empty_color
		var s := 1.0
		if i == _anim_index and _anim_t < 1.0:
			if _anim_gain:
				s = 1.0 + sin(_anim_t * PI) * 0.5
			else:
				# lost: flash white, then shrink into the empty heart
				var blink := int(_anim_t * 8.0) % 2 == 0
				color = Color.WHITE if blink else full_color
				s = lerpf(1.4, 1.0, _anim_t)
				if _anim_t > 0.75:
					color = empty_color
		var origin := Vector2(i * (heart_w + gap), 0)
		var center := origin + Vector2(heart_w, 6 * pixel) / 2.0
		draw_set_transform(center, 0.0, Vector2(s, s))
		for y in SHAPE.size():
			for x in SHAPE[y].length():
				if SHAPE[y][x] == "X":
					var p := Vector2(x * pixel, y * pixel) - Vector2(heart_w, 6 * pixel) / 2.0
					draw_rect(Rect2(p, Vector2(pixel, pixel)), color)
		if filled:
			var hp := Vector2(1 * pixel, 1 * pixel) - Vector2(heart_w, 6 * pixel) / 2.0
			draw_rect(Rect2(hp, Vector2(pixel, pixel)), Color(1, 1, 1, 0.6))
	draw_set_transform(Vector2.ZERO)
