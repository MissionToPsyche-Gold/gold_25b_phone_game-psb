extends Control
## GameFlow leaderboard (res://scenes/leaderboard.tscn), opened from the
## handoff screen's Scores button.


func _ready() -> void:
	Backdrop.use_game_layout()
	var screen := ResultsScreen.new()
	add_child(screen)
	screen.set_scoreboard_mode(GameState.round_number)
	screen.main_menu_pressed.connect(GameFlow.close_leaderboard)
	screen.show_results(GameState.leaderboard())
