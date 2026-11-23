class_name SpaceBackground
extends Control
## The animated space scene that sits behind EVERY screen, so the whole game
## matches: drifting nebula, twinkling stars, tumbling rocks, a slowly spinning
## Psyche and the Psyche spacecraft bobbing in orbit.
##
## Positions are fractions of the screen (0..1) so it works on any phone size.
## To use your own art, replace the PNGs in res://assets/art/ (same file names).

@export var show_psyche := true
@export var psyche_anchor := Vector2(0.86, 0.93)
@export var psyche_scale := 3.0
@export var show_spacecraft := true
@export var spacecraft_anchor := Vector2(0.30, 0.80)
@export var spacecraft_scale := 2.0
@export var show_planets := true
@export var planet_anchor := Vector2(0.84, 0.07)
@export var decor_alpha := 1.0   # fades the spacecraft (game screens keep it subtle)
@export var show_meteors := true

var _t := 0.0
var _psyche: Sprite2D
var _craft: Sprite2D
var _planet: Sprite2D
var _earth: Sprite2D
var _orbit: _OrbitLine


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(_Nebula.new())
	add_child(Starfield.new())
	if show_planets:
		_planet = _sprite("res://assets/art/planet.png", 2.0)
		_earth = _sprite("res://assets/art/earth.png", 2.0)
	if show_meteors:
		add_child(MeteorSpawner.new())
	if show_psyche:
		_orbit = _OrbitLine.new()
		add_child(_orbit)
		_psyche = _sprite("res://assets/art/psyche.png", psyche_scale)
	if show_spacecraft:
		_craft = _sprite("res://assets/art/spacecraft.png", spacecraft_scale)


func _sprite(path: String, s: float) -> Sprite2D:
	var sp := Sprite2D.new()
	sp.texture = load(path)
	sp.scale = Vector2(s, s)
	add_child(sp)
	return sp


## Smoothly move/resize Psyche and the spacecraft (menu <-> game layouts).
func set_layout(p_anchor: Vector2, p_scale: float, c_anchor: Vector2, c_scale: float,
		animate := true, pl_anchor := Vector2(0.84, 0.07), alpha := 1.0) -> void:
	if not animate or GameSettings.reduce_motion:
		psyche_anchor = p_anchor
		psyche_scale = p_scale
		spacecraft_anchor = c_anchor
		spacecraft_scale = c_scale
		planet_anchor = pl_anchor
		decor_alpha = alpha
		return
	var tw := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "planet_anchor", pl_anchor, 0.9)
	tw.tween_property(self, "decor_alpha", alpha, 0.9)
	tw.tween_property(self, "psyche_anchor", p_anchor, 0.9)
	tw.tween_property(self, "psyche_scale", p_scale, 0.9)
	tw.tween_property(self, "spacecraft_anchor", c_anchor, 0.9)
	tw.tween_property(self, "spacecraft_scale", c_scale, 0.9)


func _process(delta: float) -> void:
	var still := GameSettings.reduce_motion
	if not still:
		_t += delta
	if _psyche:
		_psyche.position = size * psyche_anchor
		_psyche.scale = Vector2.ONE * psyche_scale
		_psyche.rotation = _t * 0.03
		_orbit.center = _psyche.position
		_orbit.radius = Vector2(_psyche.texture.get_width(), _psyche.texture.get_height() * 0.5) * psyche_scale * 0.75
		_orbit.offset = _t * 12.0
	if _craft:
		_craft.scale = Vector2.ONE * spacecraft_scale
		_craft.modulate.a = decor_alpha
		_craft.position = size * spacecraft_anchor + Vector2(0, sin(_t * 1.6) * 5.0).round()
		_craft.rotation = -0.35 + cos(_t * 1.6) * 0.05
	if _planet:
		_planet.position = size * planet_anchor + Vector2(0, sin(_t * 0.8) * 3.0).round()
	if _earth:
		_earth.position = size * Vector2(0.0, 0.53)
		_earth.rotation = _t * 0.05


## Soft purple nebula band running diagonally across the screen.
class _Nebula extends Control:
	var _blobs: Array[Dictionary] = []

	func _ready() -> void:
		mouse_filter = MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		for i in 18:
			_blobs.append({"u": i / 18.0, "w": randf_range(40, 80), "h": randf_range(14, 26),
				"wobble": randf() * TAU, "c": UIStyle.NEBULA_A if i % 2 else UIStyle.NEBULA_B})

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var t := 0.0 if GameSettings.reduce_motion else Time.get_ticks_msec() / 1000.0
		for b in _blobs:
			var u := fposmod(b.u + t * 0.004, 1.0)
			var p := Vector2(lerpf(-0.2, 1.2, u) * size.x,
				lerpf(1.05, 0.15, u) * size.y + sin(u * 9.0 + b.wobble) * 18.0)
			draw_set_transform(p, -0.9, Vector2(b.w / 10.0, b.h / 10.0))
			draw_circle(Vector2.ZERO, 10.0, Color(b.c, 0.45))
		draw_set_transform(Vector2.ZERO)


## Dashed orbit path around Psyche.
class _OrbitLine extends Control:
	var center := Vector2.ZERO
	var radius := Vector2(100, 40)
	var offset := 0.0

	func _ready() -> void:
		mouse_filter = MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(PRESET_FULL_RECT)

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var steps := 48
		for i in steps:
			if (i + int(offset)) % 2 == 0:
				continue
			var a0 := TAU * i / steps - 0.35
			var a1 := TAU * (i + 0.6) / steps - 0.35
			var p0 := center + Vector2(cos(a0) * radius.x, sin(a0) * radius.y).rotated(-0.35)
			var p1 := center + Vector2(cos(a1) * radius.x, sin(a1) * radius.y).rotated(-0.35)
			draw_line(p0, p1, Color(UIStyle.MAGENTA, 0.45), 2.0)
