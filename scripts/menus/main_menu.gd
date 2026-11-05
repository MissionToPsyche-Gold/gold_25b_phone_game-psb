extends Control
## Start screen: animated space scene, logo, and three buttons.
## The logo drops in, buttons pop in one by one, then the logo gently bobs.

const GAME_SCENE := "res://scenes/player_setup.tscn"   # GameFlow "setup" phase
const HOW_TO_PLAY_SCENE := "res://scenes/how_to_play.tscn"
const SETTINGS_SCENE := "res://scenes/settings.tscn"

var _logo: Control
var _buttons: Array[FxButton] = []


func _ready() -> void:
	Backdrop.use_menu_layout()

	var column := ResponsiveColumn.new()
	column.top_margin = 48
	add_child(column)
	var content := UIStyle.vbox(0)
	column.add_child(content)

	_logo = _build_logo()
	content.add_child(_logo)
	content.add_child(UIStyle.spacer(36, false))

	var buttons := UIStyle.vbox(14)
	content.add_child(buttons)
	for spec in [["Start mission", "Orange", GAME_SCENE],
			["How to play", "Cyan", HOW_TO_PLAY_SCENE],
			["Settings", "Purple", SETTINGS_SCENE]]:
		var b := UIStyle.button("%s" % spec[0], spec[1], 58)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_constant_override("h_separation", 12)
		var chevron := UIStyle.label(">", UIStyle.FONT_H2, UIStyle.ACCENTS[spec[1]], true, HORIZONTAL_ALIGNMENT_RIGHT, false)
		chevron.set_anchors_preset(PRESET_RIGHT_WIDE)
		chevron.offset_left = -40
		chevron.offset_right = -16
		chevron.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		b.add_child(chevron)
		var path: String = spec[2]
		b.pressed.connect(func():
			if path == GAME_SCENE:
				GameState.clear_session()   # fresh session (report SF27)
			SceneTransition.change_scene(path))
		buttons.add_child(b)
		_buttons.append(b)

	content.add_child(UIStyle.spacer(14, false))
	var footer := UIStyle.label("A student capstone project inspired by NASA's Psyche mission",
		UIStyle.FONT_SMALL, Color(UIStyle.TEXT_DIM, 0.85), false, HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(footer)

	_play_intro.call_deferred()


func _build_logo() -> Control:
	var v := UIStyle.vbox(-6)
	v.add_child(UIStyle.heading("COSMIC", UIStyle.FONT_LOGO, UIStyle.TEXT))
	v.add_child(UIStyle.heading("QUEST", UIStyle.FONT_LOGO + 6, UIStyle.CYAN))
	var sub := UIStyle.heading("- PSYCHE -", UIStyle.FONT_H2, UIStyle.ORANGE)
	sub.add_theme_constant_override("outline_size", 6)
	v.add_child(UIStyle.spacer(10, false))
	v.add_child(sub)
	return v


func _play_intro() -> void:
	if GameSettings.reduce_motion:
		_buttons[0].grab_focus()
		return
	# The logo slides down from above with a bounce
	var home := _logo.position
	_logo.position.y = home.y - 260
	var tw := create_tween()
	tw.tween_property(_logo, "position:y", home.y, 0.8).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	# Buttons pop in one after another
	for i in _buttons.size():
		var b := _buttons[i]
		b.modulate.a = 0.0
		b.scale = Vector2(0.6, 0.6)
		var bt := create_tween().set_parallel()
		bt.tween_property(b, "modulate:a", 1.0, 0.25).set_delay(0.55 + i * 0.12)
		bt.tween_property(b, "scale", Vector2.ONE, 0.35).set_delay(0.55 + i * 0.12) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished
	# Gentle idle bob on the logo
	var bob := create_tween().set_loops()
	bob.tween_property(_logo, "position:y", home.y - 5, 1.6).set_trans(Tween.TRANS_SINE)
	bob.tween_property(_logo, "position:y", home.y, 1.6).set_trans(Tween.TRANS_SINE)
