extends Node
## Autoload "UITheme": applies the shared space theme to the whole game window,
## so every Button, Label, Panel and LineEdit in every scene matches.
## The look itself is defined in res://scripts/ui/ui_style.gd.

var theme: Theme


func _ready() -> void:
	theme = UIStyle.make_theme()
	get_tree().root.theme = theme
