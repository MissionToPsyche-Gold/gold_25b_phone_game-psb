class_name ResponsiveColumn
extends MarginContainer
## Full-screen container that keeps content in a phone-width column:
## 16 px side margins on a phone, centered column on wider screens.

@export var max_width := UIStyle.MAX_CONTENT_WIDTH
@export var side_margin := UIStyle.MARGIN
@export var top_margin := 20
@export var bottom_margin := 20


func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	resized.connect(_update)
	_update()


func _update() -> void:
	var side := maxi(side_margin, int((size.x - max_width) / 2.0))
	add_theme_constant_override("margin_left", side)
	add_theme_constant_override("margin_right", side)
	add_theme_constant_override("margin_top", top_margin)
	add_theme_constant_override("margin_bottom", bottom_margin)
