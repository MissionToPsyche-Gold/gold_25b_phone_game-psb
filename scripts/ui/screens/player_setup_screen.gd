class_name PlayerSetupScreen
extends UIScreen
## Choose 2, 3 or 4 players and enter a name for each (report UF-1, UF-2,
## SF01-SF04). Names are trimmed, must be 1-20 characters, and each invalid
## field gets its own error message. Emits `confirmed` with the names.

signal confirmed(names: PackedStringArray)
signal back_pressed

const MIN_PLAYERS := 2
const MAX_PLAYERS := 4
const MAX_NAME_LENGTH := 20

var _count := 2
var _count_buttons: Array[FxButton] = []
var _rows: Array[Control] = []
var _fields: Array[LineEdit] = []
var _errors: Array[Label] = []
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

	var names_panel := UIStyle.panel("Cyan")
	content.add_child(names_panel)
	var names_col := UIStyle.vbox(8)
	names_panel.add_child(names_col)
	names_col.add_child(UIStyle.label("Player names", UIStyle.FONT_BODY, UIStyle.CYAN, true))
	for i in MAX_PLAYERS:
		var row := UIStyle.vbox(4)
		names_col.add_child(row)
		var line := UIStyle.hbox(10)
		row.add_child(line)
		line.add_child(UIStyle.player_chip(i, 18))
		var field := LineEdit.new()
		field.placeholder_text = "Player %d name" % (i + 1)
		field.max_length = MAX_NAME_LENGTH
		field.custom_minimum_size.y = 48
		field.size_flags_horizontal = SIZE_EXPAND_FILL
		field.select_all_on_focus = true
		field.text_changed.connect(func(_t): _errors[i].visible = false)
		field.text_submitted.connect(func(_t): _focus_next(i))
		line.add_child(field)
		var err := UIStyle.label("", UIStyle.FONT_SMALL, UIStyle.RED)
		err.visible = false
		row.add_child(err)
		_rows.append(row)
		_fields.append(field)
		_errors.append(err)

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


## Clear everything for a new session (report SF27 / SF28).
func reset() -> void:
	for f in _fields:
		f.text = ""
	for e in _errors:
		e.visible = false
	_form_error.visible = false
	_set_count(MIN_PLAYERS)
	_count_buttons[0].button_pressed = true


func on_shown() -> void:
	pop_in(_intro)


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


func _focus_next(i: int) -> void:
	if i + 1 < _count:
		_fields[i + 1].grab_focus()
	else:
		_fields[i].release_focus()


func _on_start() -> void:
	var names := PackedStringArray()
	var first_bad := -1
	for i in _count:
		var n := _fields[i].text.strip_edges()
		var problem := ""
		if n.is_empty():
			problem = "Enter a name for Player %d." % (i + 1)
		elif n.length() > MAX_NAME_LENGTH:
			problem = "Use %d characters or fewer." % MAX_NAME_LENGTH
		_errors[i].text = problem
		_errors[i].visible = problem != ""
		if problem != "" and first_bad == -1:
			first_bad = i
		names.append(n)
	if first_bad != -1:
		_form_error.text = "Fix the highlighted names to launch."
		_form_error.visible = true
		_start.shake()
		_fields[first_bad].grab_focus()
		return
	_form_error.visible = false
	confirmed.emit(names)
