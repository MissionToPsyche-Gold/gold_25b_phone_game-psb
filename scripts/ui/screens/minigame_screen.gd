class_name MinigameScreen
extends UIScreen
## Frame around every bonus challenge (report UC-5, UF-8..UF-12):
##   1. intro card: challenge name, how to play, time limit, reward -> Start
##   2. play view: player name + countdown bar + an empty SLOT where your
##      teammates' minigame scene goes
##   3. result card: success/failure, detail (e.g. "312 ms"), reward -> Continue
## Timing and win/lose rules belong to the minigame, not this screen.

signal start_pressed
signal result_continue_pressed

var _intro: Control
var _play: Control
var _result: Control

var _in_chip: ColorRect
var _in_player: Label
var _in_title: Label
var _in_body: Label
var _in_limit: Label
var _in_reward: Label
var _in_button: FxButton
var _in_card: PanelContainer

var _pl_chip: ColorRect
var _pl_player: Label
var _pl_title: Label
var timer_bar: TimerBar
var _slot: Control

var _rs_card: PanelContainer
var _rs_title: Label
var _rs_detail: Label
var _rs_reward: Label
var _rs_button: FxButton


func _ready() -> void:
	_intro = _build_intro()
	_play = _build_play()
	_result = _build_result()
	for v in [_intro, _play, _result]:
		add_child(v)
		v.visible = false


func _build_intro() -> Control:
	var column := ResponsiveColumn.new()
	var content := UIStyle.vbox(16)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(content)
	content.add_child(UIStyle.label("BONUS CHALLENGE", UIStyle.FONT_BODY, UIStyle.GOLD, true, HORIZONTAL_ALIGNMENT_CENTER))
	_in_card = UIStyle.panel("Purple")
	content.add_child(_in_card)
	var col := UIStyle.vbox(12)
	_in_card.add_child(col)
	var who := UIStyle.hbox(8)
	who.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(who)
	_in_chip = UIStyle.player_chip(0, 14)
	who.add_child(_in_chip)
	_in_player = UIStyle.label("", UIStyle.FONT_BODY, UIStyle.TEXT, true, HORIZONTAL_ALIGNMENT_CENTER, false)
	who.add_child(_in_player)
	_in_title = UIStyle.heading("", UIStyle.FONT_H1, UIStyle.CYAN)
	col.add_child(_in_title)
	_in_body = UIStyle.label("", UIStyle.FONT_BODY, UIStyle.TEXT, false, HORIZONTAL_ALIGNMENT_CENTER)
	col.add_child(_in_body)
	var facts := UIStyle.hbox(10)
	col.add_child(facts)
	_in_limit = _fact_box(facts, "Orange")
	_in_reward = _fact_box(facts, "Gold")
	_in_button = UIStyle.button("Start challenge  >", "Orange", 60)
	_in_button.pressed.connect(func():
		_in_button.disabled = true
		start_pressed.emit())
	content.add_child(_in_button)
	return column


func _fact_box(parent: Control, accent: String) -> Label:
	var p := UIStyle.panel(accent)
	p.size_flags_horizontal = SIZE_EXPAND_FILL
	parent.add_child(p)
	var l := UIStyle.label("", UIStyle.FONT_SMALL, UIStyle.ACCENTS[accent], true, HORIZONTAL_ALIGNMENT_CENTER)
	p.add_child(l)
	return l


func _build_play() -> Control:
	var column := ResponsiveColumn.new()
	column.top_margin = 12
	var content := UIStyle.vbox(10)
	column.add_child(content)
	var bar := UIStyle.panel("Purple")
	content.add_child(bar)
	var bcol := UIStyle.vbox(8)
	bar.add_child(bcol)
	var top := UIStyle.hbox(8)
	bcol.add_child(top)
	_pl_chip = UIStyle.player_chip(0, 16)
	top.add_child(_pl_chip)
	_pl_player = UIStyle.label("", UIStyle.FONT_BODY, UIStyle.TEXT, true, HORIZONTAL_ALIGNMENT_LEFT, false)
	_pl_player.size_flags_horizontal = SIZE_EXPAND_FILL
	_pl_player.clip_text = true
	top.add_child(_pl_player)
	_pl_title = UIStyle.label("", UIStyle.FONT_BODY, UIStyle.CYAN, true, HORIZONTAL_ALIGNMENT_RIGHT, false)
	top.add_child(_pl_title)
	timer_bar = TimerBar.new()
	bcol.add_child(timer_bar)
	var stage := UIStyle.panel("Cyan")
	stage.size_flags_vertical = SIZE_EXPAND_FILL
	content.add_child(stage)
	_slot = Control.new()
	_slot.name = "MinigameSlot"
	_slot.clip_contents = true
	_slot.size_flags_vertical = SIZE_EXPAND_FILL
	_slot.size_flags_horizontal = SIZE_EXPAND_FILL
	stage.add_child(_slot)
	return column


func _build_result() -> Control:
	var column := ResponsiveColumn.new()
	var content := UIStyle.vbox(16)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(content)
	_rs_card = UIStyle.panel("Green")
	content.add_child(_rs_card)
	var col := UIStyle.vbox(12)
	_rs_card.add_child(col)
	_rs_title = UIStyle.heading("", UIStyle.FONT_H1, UIStyle.GREEN)
	col.add_child(_rs_title)
	_rs_detail = UIStyle.label("", UIStyle.FONT_BODY, UIStyle.TEXT, false, HORIZONTAL_ALIGNMENT_CENTER)
	col.add_child(_rs_detail)
	_rs_reward = UIStyle.label("", UIStyle.FONT_H2, UIStyle.GOLD, true, HORIZONTAL_ALIGNMENT_CENTER)
	col.add_child(_rs_reward)
	_rs_button = UIStyle.button("Continue  >", "Orange", 58)
	_rs_button.pressed.connect(func():
		_rs_button.disabled = true    # one tap only (SF24)
		result_continue_pressed.emit())
	content.add_child(_rs_button)
	return column


func _show_view(v: Control) -> void:
	for x in [_intro, _play, _result]:
		x.visible = x == v
	if v != _play:
		pop_in([v])


## time_limit_text e.g. "30 seconds"; reward_text e.g. "Win: +10 pts"
func show_intro(player: Dictionary, title: String, instructions: String,
		time_limit_text: String, reward_text: String) -> void:
	var id: int = player.get("id", 0)
	_in_chip.color = UIStyle.player_color(id)
	_in_player.text = "%s's challenge" % player.get("name", "Player")
	_in_player.add_theme_color_override("font_color", UIStyle.player_color(id))
	_in_card.theme_type_variation = UIStyle.player_accent(id) + "Panel"
	_in_title.text = title
	_in_body.text = instructions
	_in_limit.text = time_limit_text
	_in_reward.text = reward_text
	_in_button.disabled = false
	_show_view(_intro)


## Switches to the play view and returns the empty slot. Add your minigame
## node as a child of the returned Control (it fills the cyan box).
func begin_play(player: Dictionary, title: String) -> Control:
	var id: int = player.get("id", 0)
	_pl_chip.color = UIStyle.player_color(id)
	_pl_player.text = str(player.get("name", "Player"))
	_pl_player.add_theme_color_override("font_color", UIStyle.player_color(id))
	_pl_title.text = title
	for c in _slot.get_children():
		c.queue_free()
	timer_bar.visible = true
	_show_view(_play)
	return _slot


func set_time(remaining: float, total: float) -> void:
	timer_bar.set_time(remaining, total)


## Hide the countdown for challenges without a visible time limit.
func set_timer_visible(on: bool) -> void:
	timer_bar.visible = on


func show_result(success: bool, detail: String, reward_text: String) -> void:
	_rs_card.theme_type_variation = "GreenPanel" if success else "RedPanel"
	_rs_title.text = "SUCCESS!" if success else "MISSED IT"
	_rs_title.add_theme_color_override("font_color", UIStyle.GREEN if success else UIStyle.RED)
	_rs_detail.text = detail
	_rs_reward.text = reward_text
	_rs_reward.visible = reward_text != ""
	_rs_button.disabled = false
	for c in _slot.get_children():
		c.queue_free()
	_show_view(_result)
