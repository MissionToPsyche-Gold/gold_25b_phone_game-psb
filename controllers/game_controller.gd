extends Node

var trivia_scene_path: String = "res://scenes/trivia.tscn"  # UI team: themed trivia scene (swap for the real one)
var maze_scene_path: String = "res://scenes/maze.tscn"  # UI team: themed minigame frame (hosts the real maze)
var _leaderboard_return: String = "res://scenes/player_handoff.tscn"

func open_scene(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("Scene not found: " + path)
		return
	get_tree().call_deferred("change_scene_to_file", path)

func open_current() -> void:
	match GameState.phase:
		"setup": open_scene("res://scenes/player_setup.tscn")
		"handoff": open_scene("res://scenes/player_handoff.tscn")
		"trivia": open_scene(trivia_scene_path)
		"maze": open_scene(maze_scene_path)
		"results": open_scene("res://scenes/results.tscn")

func start_activity() -> void:
	if not GameState.begin_activity().is_empty():
		open_current()

func open_leaderboard() -> void:
	if GameState.phase != "handoff" and GameState.phase != "results":
		return
	_leaderboard_return = "res://scenes/results.tscn" if GameState.phase == "results" else "res://scenes/player_handoff.tscn"
	open_scene("res://scenes/leaderboard.tscn")

func close_leaderboard() -> void:
	open_scene(_leaderboard_return)

func reset_to_setup() -> void:
	GameState.clear_session()
	open_current()
