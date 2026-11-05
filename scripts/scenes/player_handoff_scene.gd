extends Control
## GameFlow "handoff" phase (res://scenes/player_handoff.tscn).

var screen: PassDeviceScreen


func _ready() -> void:
	if GameState.phase != "handoff" or GameState.current_player() == null:
		GameFlow.open_current()
		return
	Backdrop.use_game_layout()
	screen = PassDeviceScreen.new()
	add_child(screen)
	screen.show_player(GameStateUI.player_dict(GameState.current_player()), GameState.round_number,
		GameStateUI.activity_text(GameState.next_activity))
	screen.start_turn_pressed.connect(GameFlow.start_activity)
	screen.scores_pressed.connect(GameFlow.open_leaderboard)
	screen.quit_confirmed.connect(GameStateUI.quit_to_menu)
	screen.on_shown()
