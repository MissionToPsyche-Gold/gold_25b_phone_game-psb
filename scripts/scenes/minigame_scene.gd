extends Control
## GameFlow "maze" phase (res://scenes/maze.tscn): the themed frame around a
## minigame. Intro card -> minigame in the slot -> result card.
##
## MINIGAME TEAM: set `minigame_scene` (Inspector) to your scene. Its root
## should be a Control and must have:
##     signal finished(success: bool, detail: String)
## and may have (for the countdown bar):
##     signal time_changed(remaining: float, total: float)
## Leave it empty to use the tap-the-target placeholder.

@export var activity := "maze"
@export var minigame_scene: PackedScene

var screen: MinigameScreen
var attempt_token: String
var player
var info: Dictionary
var game: Node
var _done := false


func _ready() -> void:
	if GameState.phase != activity:
		GameFlow.open_current()
		return
	Backdrop.use_game_layout()
	attempt_token = GameState.get_attempt_token()
	player = GameState.current_player()
	info = GameStateUI.MINIGAMES.get(activity, {"title": activity.capitalize(), "how": "",
		"time_text": "", "seconds": 10.0, "reward_text": ""})
	screen = MinigameScreen.new()
	add_child(screen)
	screen.start_pressed.connect(_start)
	screen.result_continue_pressed.connect(GameFlow.open_current)
	screen.show_intro(GameStateUI.player_dict(player), info.title, info.how, info.time_text, info.reward_text)


func _start() -> void:
	var slot := screen.begin_play(GameStateUI.player_dict(player), info.title)
	if minigame_scene:
		game = minigame_scene.instantiate()
	else:
		var placeholder := PlaceholderMinigame.new()
		placeholder.title = info.title
		placeholder.time_limit = info.seconds
		game = placeholder
	if game is Control:
		game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if game.has_signal("time_changed"):
		game.time_changed.connect(screen.set_time)
	else:
		screen.set_timer_visible(false)
	game.finished.connect(_on_finished)
	slot.add_child(game)


func _on_finished(success: bool, detail := "") -> void:
	if _done:
		return
	_done = true
	var before_lives: int = player.lives
	if not GameState.record_maze_result(attempt_token, success):
		return
	var gained: int = player.lives - before_lives
	var reward := "No life recovered"
	if success:
		reward = ("+%d life" % gained) if gained > 0 else "Lives already full"
	screen.show_result(success, detail, reward)
