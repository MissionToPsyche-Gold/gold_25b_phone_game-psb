class_name PassDeviceScreen
extends UIScreen
## "Pass the phone to ___" between turns, so it's always clear whose turn it is
## (report 4.1.2, SF06). Shows what's next (trivia or a bonus challenge),
## plus Scores and Quit buttons.

signal start_turn_pressed
signal scores_pressed
signal quit_confirmed

var _round: Label
var _card: PanelContainer
var _name: Label
var _next: Label
var _lives: LivesDisplay
var _score: Label
var _button: FxButton
var _quit: FxButton
var _extra_row: HBoxContainer
var _icon: RuleIcon
var _pulse: Tween
var _confirming_quit := false


func _ready() -> void:
	var column := ResponsiveColumn.new()
	add_child(column)
	var content := UIStyle.vbox(16)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(content)

	_round = UIStyle.label("ROUND 1", UIStyle.FONT_BODY, UIStyle.PURPLE, true, HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(_round)

	_card = UIStyle.panel("Orange")
	content.add_child(_card)
	var col := UIStyle.vbox(12)
	_card.add_child(col)
	_icon = RuleIcon.new()
	_icon.kind = "pass"
	col.add_child(_icon)
	col.add_child(UIStyle.label("Pass the phone to", UIStyle.FONT_BODY, UIStyle.TEXT_DIM, false, HORIZONTAL_ALIGNMENT_CENTER))
	_name = UIStyle.heading("", 38)
	col.add_child(_name)
	var stats := UIStyle.hbox(14)
	stats.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(stats)
	_lives = LivesDisplay.new()
	_lives.pixel = 4
	stats.add_child(_lives)
	_score = UIStyle.label("0 pts", UIStyle.FONT_H2, UIStyle.GOLD, true, HORIZONTAL_ALIGNMENT_CENTER, false)
	stats.add_child(_score)
	_next = UIStyle.label("", UIStyle.FONT_BODY, UIStyle.CYAN, true, HORIZONTAL_ALIGNMENT_CENTER)
	col.add_child(_next)
	col.add_child(UIStyle.label("Everyone else: no peeking!", UIStyle.FONT_SMALL, UIStyle.TEXT_DIM, false, HORIZONTAL_ALIGNMENT_CENTER))

	_button = UIStyle.button("", "Orange", 60)
	_button.pressed.connect(_on_pressed)
	content.add_child(_button)

	_extra_row = UIStyle.hbox(10)
	content.add_child(_extra_row)
	var scores := UIStyle.button("Scores", "Cyan")
	scores.size_flags_horizontal = SIZE_EXPAND_FILL
	scores.pressed.connect(scores_pressed.emit)
	_extra_row.add_child(scores)
	_quit = UIStyle.button("Quit game", "Red")
	_quit.size_flags_horizontal = SIZE_EXPAND_FILL
	_quit.pressed.connect(_on_quit)
	_extra_row.add_child(_quit)


## player = {"id","name","score","lives"}; next_text e.g. "Next: Psyche trivia question"
func show_player(player: Dictionary, round_number: int, next_text := "") -> void:
	var id: int = player.get("id", 0)
	var accent := UIStyle.player_accent(id)
	_round.text = "ROUND %d" % round_number
	_card.theme_type_variation = accent + "Panel"
	_name.text = str(player.get("name", "Player"))
	_name.add_theme_color_override("font_color", UIStyle.player_color(id))
	_lives.set_lives(int(player.get("lives", 3)), false)
	_score.text = "%d pts" % int(player.get("score", 0))
	_next.text = next_text
	_next.visible = next_text != ""
	_button.text = "I'm %s - start my turn" % _name.text
	_button.accent = accent
	_button.disabled = false
	_confirming_quit = false
	_quit.text = "Quit game"


func on_shown() -> void:
	pop_in([_round, _card, _button, _extra_row])
	if _pulse:
		_pulse.kill()
	if not GameSettings.reduce_motion:
		await get_tree().process_frame
		_name.pivot_offset = _name.size / 2
		_pulse = create_tween().set_loops()
		_pulse.tween_property(_name, "scale", Vector2(1.06, 1.06), 0.7).set_trans(Tween.TRANS_SINE)
		_pulse.tween_property(_name, "scale", Vector2.ONE, 0.7).set_trans(Tween.TRANS_SINE)


func _on_pressed() -> void:
	_button.disabled = true   # one tap only
	start_turn_pressed.emit()


func _on_quit() -> void:
	if not _confirming_quit:
		_confirming_quit = true
		_quit.text = "Tap again to quit"
		return
	quit_confirmed.emit()
