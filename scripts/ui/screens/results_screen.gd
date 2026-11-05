class_name ResultsScreen
extends UIScreen
## Final results (report UF-13, SF25, SF26) and the mid-game scoreboard.
## Rows come from GameState.leaderboard(): ranked, ties share a rank, and
## eliminated players are marked OUT.

signal play_again_pressed
signal main_menu_pressed   # "Back" in scoreboard mode

var _title: Label
var _sub: Label
var _reason: Label
var _list: VBoxContainer
var _again: FxButton
var _menu: FxButton
var _confetti: CPUParticles2D
var _scoreboard := false


func _ready() -> void:
	_confetti = CPUParticles2D.new()
	_confetti.emitting = false
	_confetti.one_shot = true
	_confetti.amount = 70
	_confetti.lifetime = 3.5
	_confetti.explosiveness = 0.6
	_confetti.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_confetti.direction = Vector2(0, 1)
	_confetti.spread = 30
	_confetti.gravity = Vector2(0, 60)
	_confetti.initial_velocity_min = 20
	_confetti.initial_velocity_max = 80
	_confetti.angular_velocity_min = -180
	_confetti.angular_velocity_max = 180
	_confetti.scale_amount_min = 3
	_confetti.scale_amount_max = 5
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.25, 0.5, 0.75, 1.0])
	g.colors = PackedColorArray([UIStyle.ORANGE, UIStyle.CYAN, UIStyle.PINK, UIStyle.GOLD, UIStyle.GREEN])
	_confetti.color_initial_ramp = g
	add_child(_confetti)

	var column := ResponsiveColumn.new()
	add_child(column)
	var content := UIStyle.vbox(14)
	column.add_child(content)
	_title = UIStyle.heading("MISSION COMPLETE", UIStyle.FONT_H1, UIStyle.GOLD)
	content.add_child(_title)
	_sub = UIStyle.label("", UIStyle.FONT_BODY, UIStyle.TEXT, true, HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(_sub)
	_reason = UIStyle.label("", UIStyle.FONT_SMALL, UIStyle.TEXT_DIM, false, HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(_reason)
	_list = UIStyle.vbox(10)
	content.add_child(UIScreen.scroll_wrap(_list))
	_again = UIStyle.button("Play again  >", "Orange", 58)
	_again.pressed.connect(play_again_pressed.emit)
	content.add_child(_again)
	_menu = UIStyle.button("Main menu", "Purple")
	_menu.pressed.connect(main_menu_pressed.emit)
	content.add_child(_menu)


## Mid-game scoreboard: no confetti, no "Play again", Back instead of Main menu.
func set_scoreboard_mode(round_number: int) -> void:
	_scoreboard = true
	_title.text = "SCOREBOARD"
	_title.add_theme_color_override("font_color", UIStyle.CYAN)
	_reason.text = "Round %d" % round_number
	_again.visible = false
	_menu.text = "<  Back"


## rows: [{"id","name","score","lives","eliminated","rank"}] sorted best first.
## A row is a winner when rank == 1 and not eliminated (team's GameState rule).
func show_results(rows: Array, end_reason := "") -> void:
	for c in _list.get_children():
		c.queue_free()
	var top := rows.filter(func(r): return int(r.get("rank", 0)) == 1 and not r.get("eliminated", false))
	if _scoreboard:
		_sub.text = ("%s is in the lead" % top[0].name) if top.size() == 1 else "Current standings"
	elif top.size() > 1:
		_sub.text = "It's a tie for first place!"
	elif top.size() == 1:
		_sub.text = "%s wins the mission!" % top[0].name
	else:
		_sub.text = "No surviving players"
	if not _scoreboard:
		_reason.text = "Game over: %s" % end_reason if end_reason != "" else ""
	_reason.visible = _reason.text != ""
	var nodes: Array = []
	for r in rows:
		var leading: bool = int(r.get("rank", 0)) == 1 and not r.get("eliminated", false)
		var row := _make_row(r, leading)
		_list.add_child(row)
		nodes.append(row)
	pop_in([_title, _sub] + nodes + [_again, _menu], 0.1, 0.1)
	if not _scoreboard and not top.is_empty() and not GameSettings.reduce_motion:
		await get_tree().process_frame
		_confetti.position = Vector2(size.x / 2, -10)
		_confetti.emission_rect_extents = Vector2(size.x / 2, 4)
		_confetti.restart()


func _make_row(r: Dictionary, leading: bool) -> PanelContainer:
	var id: int = r.get("id", 0)
	var out: bool = r.get("eliminated", false)
	var p := UIStyle.panel("Gold" if leading else "Purple")
	var h := UIStyle.hbox(10)
	p.add_child(h)
	var rank_l := UIStyle.label("#%d" % int(r.get("rank", 0)), UIStyle.FONT_H2,
		UIStyle.GOLD if leading else UIStyle.TEXT_DIM, true, HORIZONTAL_ALIGNMENT_LEFT, false)
	rank_l.custom_minimum_size.x = 40
	h.add_child(rank_l)
	h.add_child(UIStyle.player_chip(id, 16))
	var name_col := UIStyle.vbox(2)
	name_col.size_flags_horizontal = SIZE_EXPAND_FILL
	h.add_child(name_col)
	var n := UIStyle.label(str(r.get("name", "")), UIStyle.FONT_BODY, UIStyle.player_color(id), true, HORIZONTAL_ALIGNMENT_LEFT, false)
	n.clip_text = true
	n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_col.add_child(n)
	var tag := ""
	if out:
		tag = "OUT"
	elif leading:
		tag = "LEADING" if _scoreboard else "WINNER"
	if tag != "":
		name_col.add_child(UIStyle.label(tag, UIStyle.FONT_SMALL, UIStyle.RED if out else UIStyle.GOLD, true, HORIZONTAL_ALIGNMENT_LEFT, false))
	var right := UIStyle.vbox(4)
	h.add_child(right)
	right.add_child(UIStyle.label("%d pts" % int(r.get("score", 0)), UIStyle.FONT_BODY, UIStyle.TEXT, true, HORIZONTAL_ALIGNMENT_RIGHT, false))
	var hearts := LivesDisplay.new()
	hearts.pixel = 2
	hearts.size_flags_horizontal = SIZE_SHRINK_END
	right.add_child(hearts)
	hearts.set_lives(int(r.get("lives", 0)), false)
	if out:
		p.self_modulate = Color(1, 1, 1, 0.6)
	return p
