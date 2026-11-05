extends Control
## Settings: music and sound volume, and Reduce motion (turns off drifting
## stars, meteors and bouncy animations). Saved automatically.

const MENU_SCENE := "res://scenes/main_menu.tscn"


func _ready() -> void:
	Backdrop.use_game_layout()
	var column := ResponsiveColumn.new()
	add_child(column)
	var content := UIStyle.vbox(16)
	column.add_child(content)
	content.add_child(UIStyle.heading("SETTINGS", UIStyle.FONT_H1, UIStyle.PURPLE))

	var card := UIStyle.panel("Purple")
	content.add_child(card)
	var col := UIStyle.vbox(18)
	card.add_child(col)
	col.add_child(_slider_row("Music", GameSettings.music_volume, GameSettings.set_music_volume))
	col.add_child(_slider_row("Sound effects", GameSettings.sfx_volume, GameSettings.set_sfx_volume))
	var motion := CheckButton.new()
	motion.text = "Reduce motion"
	motion.button_pressed = GameSettings.reduce_motion
	motion.custom_minimum_size.y = 48
	motion.add_theme_font_size_override("font_size", UIStyle.FONT_BODY)
	motion.toggled.connect(GameSettings.set_reduce_motion)
	col.add_child(motion)
	col.add_child(UIStyle.label("Every instruction and result is shown on screen, so the game works with the sound off.",
		UIStyle.FONT_SMALL, UIStyle.TEXT_DIM))

	content.add_child(UIStyle.spacer())
	var back := UIStyle.button("<  Back", "Purple", 56)
	back.pressed.connect(func(): SceneTransition.change_scene(MENU_SCENE))
	content.add_child(back)


func _slider_row(title: String, value: int, setter: Callable) -> Control:
	var v := UIStyle.vbox(6)
	var top := UIStyle.hbox()
	v.add_child(top)
	var l := UIStyle.label(title, UIStyle.FONT_BODY, UIStyle.TEXT, true, HORIZONTAL_ALIGNMENT_LEFT, false)
	l.size_flags_horizontal = SIZE_EXPAND_FILL
	top.add_child(l)
	var val := UIStyle.label(str(value), UIStyle.FONT_BODY, UIStyle.ORANGE, true, HORIZONTAL_ALIGNMENT_RIGHT, false)
	top.add_child(val)
	var s := HSlider.new()
	s.min_value = 0
	s.max_value = 100
	s.step = 1
	s.value = value
	s.custom_minimum_size.y = 44
	s.value_changed.connect(func(x: float):
		val.text = str(int(x))
		setter.call(int(x)))
	v.add_child(s)
	return v
