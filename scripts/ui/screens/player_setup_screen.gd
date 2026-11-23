class_name PlayerSetupScreen
extends UIScreen
## Choose 2, 3 or 4 players (report UF-1, SF01, SF02) and a callsign for each.
## Sponsor change (Nov 2026): there is no typing. Each player flips through
## ready-made NASA/Psyche callsigns with < and >, so nobody can enter an
## inappropriate nickname. Two players can never hold the same callsign.
## Emits `confirmed` with the chosen callsigns.

signal confirmed(names: PackedStringArray)
signal back_pressed

const MIN_PLAYERS := 2
const MAX_PLAYERS := 4

var _count := 2
var _count_buttons: Array[FxButton] = []
var _rows: Array[Control] = []
var _name_labels: Array[Label] = []
var _selected: Array[String] = []
var _start: FxButton
var _form_error: Label
var _intro: Array = []


func _ready() -> void:
	var column := ResponsiveColumn.new()
	add_child(column)
	var content := UIStyle.vbox(14)
	column.add_child(UIScreen.scroll_wrap(content))

	var title := UIStyle.heading("MISSION CREW")
	content.add_child(title)
	var sub := UIStyle.label("Set up your team before launch.", UIStyle.FONT_BODY, UIStyle.TEXT_DIM, false, HORIZONTAL_ALIGNMENT_CENTER)
	content.add_child(sub)

	var count_panel := UIStyle.panel("Orange")
	content.add_child(count_panel)
	var count_col := UIStyle.vbox(10)
	count_panel.add_child(count_col)
	count_col.add_child(UIStyle.label("How many players?", UIStyle.FONT_BODY, UIStyle.ORANGE, true))
	var count_row := UIStyle.hbox(10)
	count_col.add_child(count_row)
	var group := ButtonGroup.new()
	for n in range(MIN_PLAYERS, MAX_PLAYERS + 1):
		var b := UIStyle.button(str(n), "Orange", 56)
		b.toggle_mode = true
		b.button_group = group
		b.add_theme_font_size_override("font_size", UIStyle.FONT_H2)
		b.size_flags_horizontal = SIZE_EXPAND_FILL
		b.pressed.connect(_set_count.bind(n))
		count_row.add_child(b)
		_count_buttons.append(b)

	var names_panel := UIStyle.panel("Magenta")
	content.add_child(names_panel)
	var names_col := UIStyle.vbox(10)
	names_panel.add_child(names_col)
	names_col.add_child(UIStyle.label("Pick your callsigns", UIStyle.FONT_BODY, UIStyle.MAGENTA, true))
	names_col.add_child(UIStyle.label("Tap < or > to flip through mission names.", UIStyle.FONT_SMALL, UIStyle.TEXT_DIM))
	for i in MAX_PLAYERS:
		var row := UIStyle.hbox(8)
		names_col.add_child(row)
		row.add_child(UIStyle.player_chip(i, 18))
		var prev := UIStyle.button("<", "Purple", 48)
		prev.custom_minimum_size = Vector2(48, 48)
		prev.tooltip_text = "Previous callsign for Player %d" % (i + 1)
		prev.pressed.connect(_cycle.bind(i, -1))
		row.add_child(prev)
		var name_label := UIStyle.label("", UIStyle.FONT_BODY, UIStyle.player_color(i), true, HORIZONTAL_ALIGNMENT_CENTER, false)
		name_label.size_flags_horizontal = SIZE_EXPAND_FILL
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_label.clip_text = true
		name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		row.add_child(name_label)
		var next := UIStyle.button(">", "Purple", 48)
		next.custom_minimum_size = Vector2(48, 48)
		next.tooltip_text = "Next callsign for Player %d" % (i + 1)
		next.pressed.connect(_cycle.bind(i, 1))
		row.add_child(next)
		_rows.append(row)
		_name_labels.append(name_label)

	_form_error = UIStyle.label("", UIStyle.FONT_SMALL, UIStyle.RED, false, HORIZONTAL_ALIGNMENT_CENTER)
	_form_error.visible = false
	content.add_child(_form_error)

	_start = UIStyle.button("Launch mission  >", "Orange", 58)
	_start.pressed.connect(_on_start)
	content.add_child(_start)
	var back := UIStyle.button("<  Back to menu", "Purple")
	back.pressed.connect(back_pressed.emit)
	content.add_child(back)

	_intro = [title, sub, count_panel, names_panel, _start, back]
	reset()


## New session: 2 players, fresh random callsigns (report SF27 / SF28).
func reset() -> void:
	_selected = Callsigns.random_distinct(MAX_PLAYERS)
	_refresh_names()
	_form_error.visible = false
	_set_count(MIN_PLAYERS)
	_count_buttons[0].button_pressed = true


func on_shown() -> void:
	pop_in(_intro)


## Callsigns of the active players, in player order.
func get_selected_names() -> PackedStringArray:
	return PackedStringArray(_selected.slice(0, _count))


## Give player `index` a callsign. Returns false (and changes nothing) if the
## name isn't in the list or another player already has it.
func set_callsign(index: int, callsign: String) -> bool:
	if index < 0 or index >= MAX_PLAYERS or not Callsigns.NAMES.has(callsign):
		return false
	for j in MAX_PLAYERS:
		if j != index and _selected[j] == callsign:
			return false
	_selected[index] = callsign
	_refresh_names()
	return true


## Step player `index` to the next (dir = 1) or previous (dir = -1) free callsign.
func _cycle(index: int, dir: int) -> void:
	var names := Callsigns.NAMES
	var pos := names.find(_selected[index])
	for step in range(1, names.size()):
		var candidate: String = names[posmod(pos + dir * step, names.size())]
		if set_callsign(index, candidate):
			return


func _refresh_names() -> void:
	for i in _name_labels.size():
		_name_labels[i].text = _selected[i]


func _set_count(n: int) -> void:
	_count = clampi(n, MIN_PLAYERS, MAX_PLAYERS)
	for i in MAX_PLAYERS:
		_rows[i].visible = i < _count
	_form_error.visible = false


## Show an error that came from the game logic (e.g. GameState.validate_names).
func show_form_error(message: String) -> void:
	_form_error.text = message
	_form_error.visible = true
	_start.shake()


func _on_start() -> void:
	_form_error.visible = false
	confirmed.emit(get_selected_names())
