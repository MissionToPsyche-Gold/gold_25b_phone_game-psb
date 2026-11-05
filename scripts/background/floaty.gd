class_name Floaty
extends Node
## Add as a CHILD of any Sprite2D / Control to make it bob and/or spin.
## Handy for minigame decorations (e.g. the spacecraft in the Maze).

@export var bob_amplitude := 6.0   # pixels up/down
@export var bob_period := 3.0      # seconds per bob
@export var sway_degrees := 0.0    # gentle tilt
@export var spin_speed := 0.0      # degrees/sec

var _parent: CanvasItem
var _base_pos: Vector2
var _base_rot: float
var _t: float
var _spin := 0.0


func _ready() -> void:
	_parent = get_parent()
	_base_pos = _parent.position
	_base_rot = _parent.rotation_degrees
	_t = randf() * bob_period


func _process(delta: float) -> void:
	if GameSettings.reduce_motion:
		return
	_t += delta
	_spin += spin_speed * delta
	var wave := sin(_t * TAU / bob_period)
	_parent.position = _base_pos + Vector2(0, wave * bob_amplitude)
	_parent.rotation_degrees = _base_rot + _spin + cos(_t * TAU / bob_period) * sway_degrees
