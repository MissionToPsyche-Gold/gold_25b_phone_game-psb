extends GutTest
## TS-006: Bonus Challenge (minigame frame + GameState + maze)
## Requirements: UF-8 to UF-12, SF15-SF24, UC-5; sponsor request: story for each minigame

const MAZE_FRAME := "res://scenes/maze.tscn"


func before_each() -> void:
	GameState.clear_session()
	GameState.start_session(["Metal Core", "Solar Sail"], 1)
	# Both players answer: Metal Core wrong (loses a life), Solar Sail right.
	GameState.begin_activity()
	GameState.record_trivia_result(GameState.get_attempt_token(), false)
	GameState.begin_activity()
	GameState.record_trivia_result(GameState.get_attempt_token(), true)
	GameState.begin_activity()   # -> maze for Metal Core


func after_each() -> void:
	GameState.clear_session()


func _all_text(node: Node) -> String:
	var out := ""
	for l in node.find_children("*", "Label", true, false):
		out += l.text + "\n"
	return out


## TC-023 (Unit): every minigame has a short mission story tied to Psyche.
func test_tc023_every_minigame_has_story() -> void:
	for key in GameStateUI.MINIGAMES:
		var info: Dictionary = GameStateUI.MINIGAMES[key]
		assert_true(info.has("story"), "%s has a story" % key)
		if info.has("story"):
			assert_gt(str(info.story).length(), 20, "%s story is a real sentence" % key)
			assert_string_contains(str(info.story), "Psyche", "%s story mentions Psyche" % key)


## TC-024 (Integration): the bonus challenge intro shows the mission story.
func test_tc024_intro_shows_story() -> void:
	assert_eq(GameState.phase, "maze")
	var frame = load(MAZE_FRAME).instantiate()
	add_child_autofree(frame)
	await wait_physics_frames(2)
	var story: String = GameStateUI.MINIGAMES.maze.get("story", "<no story>")
	assert_string_contains(_all_text(frame), story, "Intro card shows the story")


## TC-025 (Integration): winning the maze restores one life exactly once and
## the result card says so.
func test_tc025_maze_win_restores_one_life_once() -> void:
	var player = GameState.current_player()
	assert_eq(player.lives, 2, "Starts the challenge with 2 lives")
	var frame = load(MAZE_FRAME).instantiate()
	add_child_autofree(frame)
	await wait_physics_frames(2)
	frame._start()
	frame._on_finished(true, "test win")
	frame._on_finished(true, "test win again")
	assert_eq(player.lives, 3, "+1 life, only once")
	assert_string_contains(_all_text(frame), "+1 life")
