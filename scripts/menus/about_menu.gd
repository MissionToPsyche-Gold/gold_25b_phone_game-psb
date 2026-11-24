extends Control
## About page: the team, what the game is, and the Psyche mission.
## Content lives in res://scripts/ui/about_info.gd.

const MENU_SCENE := "res://scenes/main_menu.tscn"


func _ready() -> void:
	Backdrop.use_game_layout()
	var column := ResponsiveColumn.new()
	add_child(column)
	var outer := UIStyle.vbox(14)
	column.add_child(outer)
	outer.add_child(UIStyle.heading("ABOUT", UIStyle.FONT_H1, UIStyle.GOLD))

	var content := UIStyle.vbox(14)
	outer.add_child(UIScreen.scroll_wrap(content))

	var team := _section(content, "The team", "Orange")
	for n in AboutInfo.TEAM:
		team.add_child(UIStyle.label(n, UIStyle.FONT_BODY, UIStyle.TEXT, true))
	team.add_child(UIStyle.label(AboutInfo.TEAM_NOTE, UIStyle.FONT_SMALL, UIStyle.TEXT_DIM))

	var project := _section(content, "About this game", "Magenta")
	project.add_child(UIStyle.label(AboutInfo.PROJECT, UIStyle.FONT_SMALL, UIStyle.TEXT))

	var mission := _section(content, "The Psyche mission", "Gold")
	mission.add_child(UIStyle.label(AboutInfo.MISSION, UIStyle.FONT_SMALL, UIStyle.TEXT))

	var disclaimer := _section(content, "Disclaimer", "Orange")
	disclaimer.add_child(UIStyle.label(AboutInfo.DISCLAIMER, UIStyle.FONT_SMALL, UIStyle.TEXT))

	var references := _section(content, "References", "Magenta")
	references.add_child(UIStyle.label(AboutInfo.REFERENCE, UIStyle.FONT_SMALL, UIStyle.TEXT))

	var back := UIStyle.button("<  Back", "Purple", 56)
	back.pressed.connect(func(): SceneTransition.change_scene(MENU_SCENE))
	outer.add_child(back)


func _section(parent: Control, title: String, accent: String) -> VBoxContainer:
	var p := UIStyle.panel(accent)
	parent.add_child(p)
	var col := UIStyle.vbox(6)
	p.add_child(col)
	col.add_child(UIStyle.label(title, UIStyle.FONT_BODY, UIStyle.ACCENTS[accent], true))
	return col
