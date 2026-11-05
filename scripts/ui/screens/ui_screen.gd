class_name UIScreen
extends Control
## Base for every screen: fills the window, builds its layout in code, and has
## a small helper for the "pop in one after another" intro animation.


func _init() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE


## Fade + slide each node in, one after another.
func pop_in(nodes: Array, start_delay := 0.05, step := 0.07) -> void:
	if GameSettings.reduce_motion:
		for n: Control in nodes:
			n.modulate.a = 1.0
		return
	for i in nodes.size():
		var n: Control = nodes[i]
		n.modulate.a = 0.0
		var tw := n.create_tween()
		tw.tween_interval(start_delay + i * step)
		tw.tween_property(n, "modulate:a", 1.0, 0.2)


## Wrap content in a scroll area (vertical only, never sideways - SP01).
static func scroll_wrap(content: Control) -> ScrollContainer:
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.size_flags_vertical = SIZE_EXPAND_FILL
	sc.size_flags_horizontal = SIZE_EXPAND_FILL
	content.size_flags_horizontal = SIZE_EXPAND_FILL
	sc.add_child(content)
	return sc
