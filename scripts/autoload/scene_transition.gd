extends CanvasLayer
## Autoload "SceneTransition": fade-to-space between scenes.
##   SceneTransition.change_scene("res://scenes/game.tscn")

@export var fade_color := UIStyle.BG
@export var fade_time := 0.3

var _rect := ColorRect.new()
var _busy := false


func _ready() -> void:
	layer = 100
	_rect.color = Color(fade_color, 0.0)
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)


func change_scene(path: String) -> void:
	if _busy:
		return
	if path.is_empty() or not ResourceLoader.exists(path):
		push_warning("SceneTransition: scene not found: %s" % path)
		return
	_busy = true
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP   # block taps mid-fade
	var tw := create_tween()
	tw.tween_property(_rect, "color:a", 1.0, fade_time)
	await tw.finished
	get_tree().change_scene_to_file(path)
	tw = create_tween()
	tw.tween_property(_rect, "color:a", 0.0, fade_time)
	await tw.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false
