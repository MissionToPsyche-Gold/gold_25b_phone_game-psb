extends Control
## GameFlow "setup" phase (res://scenes/player_setup.tscn).
## Player count + names -> GameState.start_session() -> rules -> GameFlow.

## 0 = no round limit: the game ends when one player is left or the
## questions run out (report UC-2). The team's demo used 3 for testing.
@export var round_limit := 0

var setup: PlayerSetupScreen
var rules: RulesScreen


func _ready() -> void:
	Backdrop.use_game_layout()
	setup = PlayerSetupScreen.new()
	add_child(setup)
	rules = RulesScreen.new()
	rules.visible = false
	add_child(rules)
	setup.confirmed.connect(_on_confirmed)
	setup.back_pressed.connect(GameStateUI.quit_to_menu)
	rules.ready_pressed.connect(GameFlow.open_current)
	rules.back_pressed.connect(_back_to_setup)
	setup.on_shown()


func _on_confirmed(names: PackedStringArray) -> void:
	var error := GameState.start_session(Array(names), round_limit)
	if not error.is_empty():
		setup.show_form_error(error)
		return
	setup.visible = false
	rules.visible = true
	rules.on_shown()


func _back_to_setup() -> void:
	GameState.clear_session()
	rules.visible = false
	setup.visible = true
