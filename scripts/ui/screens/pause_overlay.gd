class_name PauseOverlay
extends Control
## Pause menu during trivia turns. "Quit" asks for a second tap so nobody
## loses the game by accident.

signal resume_pressed
signal quit_pressed

var _quit: FxButton
var _confirming := false


func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP   # blocks taps on the game underneath
	var dim := ColorRect.new()
	dim.color = Color(UIStyle.BG, 0.8)
	dim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(dim)
	var column := ResponsiveColumn.new()
	add_child(column)
	var center := UIStyle.vbox(14)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(center)
	var card := UIStyle.panel("Purple")
	center.add_child(card)
	var col := UIStyle.vbox(14)
	card.add_child(col)
	col.add_child(UIStyle.heading("PAUSED"))
	var resume := UIStyle.button("Resume", "Orange", 56)
	resume.pressed.connect(func(): resume_pressed.emit())
	col.add_child(resume)
	_quit = UIStyle.button("Quit to main menu", "Red")
	_quit.pressed.connect(_on_quit)
	col.add_child(_quit)


func open() -> void:
	_confirming = false
	_quit.text = "Quit to main menu"
	visible = true


func _on_quit() -> void:
	if not _confirming:
		_confirming = true
		_quit.text = "Tap again to quit (game ends)"
		return
	quit_pressed.emit()
