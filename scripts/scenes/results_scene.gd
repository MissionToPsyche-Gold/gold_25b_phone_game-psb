extends Control
## GameFlow "results" phase (res://scenes/results.tscn).


func _ready() -> void:
	if GameState.phase != "results":
		GameFlow.open_current()
		return
	Backdrop.use_game_layout()
	var screen := ResultsScreen.new()
	add_child(screen)
	screen.play_again_pressed.connect(GameFlow.reset_to_setup)
	screen.main_menu_pressed.connect(GameStateUI.quit_to_menu)
	screen.show_results(GameState.leaderboard(), GameState.end_reason)
