extends Control
## "How to play" from the main menu: the same rule cards shown in-game.

const MENU_SCENE := "res://scenes/main_menu.tscn"


func _ready() -> void:
	Backdrop.use_game_layout()
	var column := ResponsiveColumn.new()
	add_child(column)
	var content := UIStyle.vbox(14)
	column.add_child(content)
	content.add_child(UIStyle.heading("HOW TO PLAY", UIStyle.FONT_H1, UIStyle.CYAN))
	var pager := RulesPager.new()
	pager.finish_text = "Got it!"
	pager.size_flags_vertical = SIZE_EXPAND_FILL
	pager.finished.connect(func(): SceneTransition.change_scene(MENU_SCENE))
	pager.exited.connect(func(): SceneTransition.change_scene(MENU_SCENE))
	content.add_child(pager)
