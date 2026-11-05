class_name PlayerHud
extends PanelContainer
## Top bar during a turn: whose turn it is, score, lives and round (report UF-7,
## UC-6). When values change it counts the score up and floats "+10" / "-1 life"
## so players can see what their answer did.

signal pause_pressed

var _chip: ColorRect
var _name: Label
var _score: Label
var _round: Label
var _lives: LivesDisplay
var _shown_score := 0
var _player_id := -1


func _ready() -> void:
	theme_type_variation = "PurplePanel"
	var col := UIStyle.vbox(6)
	add_child(col)

	var top := UIStyle.hbox(8)
	col.add_child(top)
	_chip = UIStyle.player_chip(0, 16)
	top.add_child(_chip)
	_name = UIStyle.label("", UIStyle.FONT_H2, UIStyle.TEXT, true, HORIZONTAL_ALIGNMENT_LEFT, false)
	_name.size_flags_horizontal = SIZE_EXPAND_FILL
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_name.clip_text = true
	top.add_child(_name)
	var pause := UIStyle.button("II", "Purple", 44)
	pause.custom_minimum_size = Vector2(48, 44)
	pause.tooltip_text = "Pause"
	pause.pressed.connect(pause_pressed.emit)
	top.add_child(pause)

	var bottom := UIStyle.hbox(10)
	col.add_child(bottom)
	_round = UIStyle.label("Round 1", UIStyle.FONT_SMALL, UIStyle.TEXT_DIM, false, HORIZONTAL_ALIGNMENT_LEFT, false)
	_round.size_flags_horizontal = SIZE_EXPAND_FILL
	bottom.add_child(_round)
	_score = UIStyle.label("0 pts", UIStyle.FONT_BODY, UIStyle.GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT, false)
	bottom.add_child(_score)
	_lives = LivesDisplay.new()
	_lives.size_flags_vertical = SIZE_SHRINK_CENTER
	bottom.add_child(_lives)


## player = {"id", "name", "score", "lives"}. animate=true shows the change.
func set_player(player: Dictionary, round_number: int, animate := false) -> void:
	var id: int = player.get("id", 0)
	var new_score: int = player.get("score", 0)
	var new_lives: int = player.get("lives", 3)
	var same_player := id == _player_id
	_player_id = id
	_chip.color = UIStyle.player_color(id)
	_name.text = str(player.get("name", "Player"))
	_name.add_theme_color_override("font_color", UIStyle.player_color(id))
	_round.text = "Round %d" % round_number
	var do_anim := animate and same_player
	var score_delta := new_score - _shown_score
	var lives_delta := new_lives - _lives.lives
	_lives.set_lives(new_lives, do_anim)
	if do_anim and score_delta != 0:
		_float_text(("+%d" % score_delta) if score_delta > 0 else str(score_delta), UIStyle.GOLD, _score)
		var tw := create_tween()
		tw.tween_method(_set_score_text, _shown_score, new_score, 0.5)
	else:
		_set_score_text(new_score)
	if do_anim and lives_delta != 0:
		var txt := ("+%d life" % lives_delta) if lives_delta > 0 else ("%d life" % lives_delta)
		_float_text(txt, UIStyle.RED if lives_delta < 0 else UIStyle.GREEN, _lives)


func _set_score_text(v: int) -> void:
	_shown_score = v
	_score.text = "%d pts" % v


func _float_text(text: String, color: Color, near: Control) -> void:
	var l := UIStyle.label(text, UIStyle.FONT_BODY, color, true, HORIZONTAL_ALIGNMENT_CENTER, false)
	l.add_theme_constant_override("outline_size", 6)
	l.add_theme_color_override("font_outline_color", UIStyle.BG)
	l.top_level = true
	add_child(l)
	l.global_position = near.global_position + Vector2(-8, -2)
	var tw := l.create_tween().set_parallel()
	tw.tween_property(l, "global_position:y", l.global_position.y - 22, 0.9).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.4).set_delay(0.9)
	tw.chain().tween_callback(l.queue_free)
