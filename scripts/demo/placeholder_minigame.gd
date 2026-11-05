class_name PlaceholderMinigame
extends Control
## DEMO ONLY. Stand-in for your teammates' minigames so the UI flow can be
## tested: tap the target 5 times before time runs out.
##
## It shows the shape a real minigame should have:
##   - it gets added inside the minigame slot and fills it
##   - it owns its own timer and rules
##   - it emits time_changed every frame and finished once at the end

signal time_changed(remaining: float, total: float)
signal finished(success: bool, detail: String)

var title := "Challenge"
var time_limit := 8.0
var taps_needed := 5

var _remaining := 0.0
var _taps := 0
var _done := false
var _target: FxButton
var _count: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_remaining = time_limit
	var col := UIStyle.vbox(14)
	col.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(col)
	col.add_child(UIStyle.label("Placeholder: the real %s goes here." % title,
		UIStyle.FONT_SMALL, UIStyle.TEXT_DIM, false, HORIZONTAL_ALIGNMENT_CENTER))
	_count = UIStyle.label("", UIStyle.FONT_H2, UIStyle.CYAN, true, HORIZONTAL_ALIGNMENT_CENTER)
	col.add_child(_count)
	var holder := CenterContainer.new()
	col.add_child(holder)
	_target = UIStyle.button("TAP!", "Orange", 110)
	_target.custom_minimum_size = Vector2(150, 110)
	_target.add_theme_font_size_override("font_size", UIStyle.FONT_H1)
	_target.pressed.connect(_on_tap)
	holder.add_child(_target)
	_update_count()


func _process(delta: float) -> void:
	if _done:
		return
	_remaining -= delta
	time_changed.emit(_remaining, time_limit)
	if _remaining <= 0.0:
		_finish(false)


func _on_tap() -> void:
	if _done:
		return
	_taps += 1
	_update_count()
	if _taps >= taps_needed:
		_finish(true)


func _update_count() -> void:
	_count.text = "%d / %d taps" % [_taps, taps_needed]


func _finish(success: bool) -> void:
	_done = true
	var used := time_limit - maxf(_remaining, 0.0)
	var detail := ("Done in %.1f seconds." % used) if success else "Time ran out after %d taps." % _taps
	finished.emit(success, detail)
