class_name MeteorSpawner
extends Control
## Tumbling asteroids and shooting stars drifting across the screen.
## Purely decorative: nothing is shot or destroyed (report EC-2 / SE06).

@export var rock_textures: Array[Texture2D] = []
@export var rock_interval := Vector2(1.8, 4.0)          # seconds between rocks
@export var shooting_star_interval := Vector2(2.5, 6.0) # seconds between streaks
@export var rock_speed := Vector2(40.0, 90.0)           # px/sec
@export var shooting_star_color := Color("#fff6c8")


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	if rock_textures.is_empty():
		for i in range(1, 5):
			rock_textures.append(load("res://assets/art/rock_%d.png" % i))
	_make_timer(rock_interval, _spawn_rock)
	_make_timer(shooting_star_interval, _spawn_shooting_star)


func _make_timer(interval: Vector2, fn: Callable) -> void:
	var t := Timer.new()
	t.one_shot = true
	add_child(t)
	t.timeout.connect(func():
		if not GameSettings.reduce_motion:
			fn.call()
		t.start(randf_range(interval.x, interval.y)))
	t.start(randf_range(interval.x, interval.y) * 0.5)


func _spawn_rock() -> void:
	var rock := Sprite2D.new()
	rock.texture = rock_textures.pick_random()
	var s := randf_range(1.0, 2.6)          # bigger = closer = brighter + faster
	rock.scale = Vector2(s, s)
	rock.modulate = Color(1, 1, 1, lerpf(0.45, 0.95, (s - 1.0) / 1.6))
	var start := Vector2(size.x + 40, randf_range(-40, size.y * 0.75))
	var dir := Vector2(-1, randf_range(0.2, 0.6)).normalized()
	var dist := size.length() + 120.0
	var dur := dist / (randf_range(rock_speed.x, rock_speed.y) * s * 0.6)
	rock.position = start
	add_child(rock)
	var tw := rock.create_tween().set_parallel()
	tw.tween_property(rock, "position", start + dir * dist, dur)
	tw.tween_property(rock, "rotation", randf_range(-TAU, TAU), dur)
	tw.chain().tween_callback(rock.queue_free)


func _spawn_shooting_star() -> void:
	var star := Line2D.new()
	star.width = 2
	var g := Gradient.new()
	g.set_color(0, Color(shooting_star_color, 0.0))
	g.set_color(1, shooting_star_color)
	star.gradient = g
	var dir := Vector2(-1, 0.5).normalized()
	var length := randf_range(30, 80)
	star.points = PackedVector2Array([-dir * length, Vector2.ZERO])
	star.position = Vector2(randf_range(size.x * 0.3, size.x + 60), randf_range(-10, size.y * 0.45))
	add_child(star)
	var tw := star.create_tween().set_parallel()
	tw.tween_property(star, "position", star.position + dir * randf_range(220, 380), 0.7)
	tw.tween_property(star, "modulate:a", 0.0, 0.3).set_delay(0.4)
	tw.chain().tween_callback(star.queue_free)
