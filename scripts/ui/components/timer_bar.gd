class_name TimerBar
extends Control
## Segmented countdown bar for minigames. DISPLAY ONLY: the minigame owns the
## real timer and calls set_time(remaining, total) every frame.
## Shows seconds as text as well as color, so it works with sound off (SP03).

@export var segments := 20

var _remaining := 1.0
var _total := 1.0
var _label: Label


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	custom_minimum_size.y = 26
	_label = UIStyle.label("", UIStyle.FONT_SMALL, UIStyle.TEXT, true, HORIZONTAL_ALIGNMENT_RIGHT, false)
	_label.set_anchors_preset(PRESET_RIGHT_WIDE)
	_label.offset_left = -56
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_label)


func set_time(remaining: float, total: float) -> void:
	_remaining = maxf(remaining, 0.0)
	_total = maxf(total, 0.001)
	_label.text = "%ds" % ceili(_remaining)
	queue_redraw()


func _draw() -> void:
	var frac := _remaining / _total
	var bar_w := size.x - 60
	var seg_w := bar_w / segments
	var lit := ceili(frac * segments)
	var c := UIStyle.CYAN
	if frac < 0.5:
		c = UIStyle.ORANGE
	if frac < 0.25:
		c = UIStyle.RED
		if not GameSettings.reduce_motion and int(Time.get_ticks_msec() / 200) % 2 == 0:
			c = c.lightened(0.35)
	draw_rect(Rect2(0, 0, bar_w, size.y), UIStyle.PANEL)
	for i in segments:
		var r := Rect2(i * seg_w + 2, 3, seg_w - 3, size.y - 6)
		draw_rect(r, c if i < lit else Color("#2a1f4f"))
	draw_rect(Rect2(0, 0, bar_w, size.y), c, false, 2.0)
