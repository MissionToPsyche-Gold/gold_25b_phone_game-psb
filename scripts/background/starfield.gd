class_name Starfield
extends Control
## Twinkling, slowly drifting pixel stars. Big stars flash a 4-point sparkle.
## Fills its parent; the star count scales with screen size.

@export var stars_per_10k_px := 8.0
@export var drift_speed := 6.0   # px/sec to the left (paused when Reduce motion is on)
@export var colors: Array[Color] = [
	Color("#fff6c8"), Color("#9fe8ff"), Color("#ffb3e6"), Color("#c9a8ff"), Color("#ffd36b"),
]

var _stars: Array[Dictionary] = []


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	resized.connect(_generate)
	_generate()


func _generate() -> void:
	_stars.clear()
	if size.x < 1 or size.y < 1:
		return
	var count := clampi(int(size.x * size.y / 10000.0 * stars_per_10k_px), 40, 500)
	for i in count:
		_stars.append({
			"pos": Vector2(randf() * size.x, randf() * size.y),
			"size": [1, 1, 1, 2, 2, 3].pick_random(),
			"color": colors.pick_random(),
			"phase": randf() * TAU,
			"speed": randf_range(0.8, 3.0),
			"depth": randf_range(0.3, 1.0),
		})


func _process(delta: float) -> void:
	if drift_speed != 0.0 and not GameSettings.reduce_motion:
		for s in _stars:
			s.pos.x -= drift_speed * s.depth * delta
			if s.pos.x < -4:
				s.pos.x = size.x + 4
				s.pos.y = randf() * size.y
	queue_redraw()


func _draw() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	for s in _stars:
		var twinkle := 0.5 + 0.5 * sin(t * s.speed + s.phase)
		var c: Color = s.color
		c.a = lerpf(0.25, 1.0, twinkle)
		var p: Vector2 = s.pos.floor()
		var sz: int = s.size
		draw_rect(Rect2(p, Vector2(sz, sz)), c)
		if sz == 3 and twinkle > 0.8:
			var arm := int(lerpf(2, 6, (twinkle - 0.8) / 0.2))
			var center := p + Vector2(1, 1)
			draw_rect(Rect2(center + Vector2(-arm, 0), Vector2(arm * 2 + 1, 1)), c)
			draw_rect(Rect2(center + Vector2(0, -arm), Vector2(1, arm * 2 + 1)), c)
