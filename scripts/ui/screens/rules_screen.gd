class_name RulesScreen
extends UIScreen
## Shown once after setup: confirms the crew is ready and shows the rules,
## ending with a "Ready!" button (report UC-1 step 8, UC-2 steps 2-3).

signal ready_pressed
signal back_pressed

var _pager: RulesPager
var _title: Label


func _ready() -> void:
	var column := ResponsiveColumn.new()
	add_child(column)
	var content := UIStyle.vbox(14)
	column.add_child(content)
	_title = UIStyle.heading("CREW READY!", UIStyle.FONT_H1, UIStyle.GREEN)
	content.add_child(_title)
	content.add_child(UIStyle.label("Here's how the mission works.", UIStyle.FONT_BODY, UIStyle.TEXT_DIM, false, HORIZONTAL_ALIGNMENT_CENTER))
	_pager = RulesPager.new()
	_pager.finish_text = "Ready!"
	_pager.size_flags_vertical = SIZE_EXPAND_FILL
	_pager.finished.connect(ready_pressed.emit)
	_pager.exited.connect(back_pressed.emit)
	content.add_child(_pager)


func on_shown() -> void:
	_pager.reset()
	pop_in([_title, _pager])
