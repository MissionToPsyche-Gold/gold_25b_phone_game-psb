extends GutTest
## TS-009: Game Flow (GameFlow controller + GameState + scenes)
## Requirements: UF-1 to UF-14, UC-1 to UC-6, 6.1 MVC


func after_each() -> void:
	GameState.clear_session()


func _current() -> Node:
	return get_tree().current_scene


## TC-032 (Integration): a 2-player, 1-round session runs from setup through
## trivia and the bonus challenge to the results screen.
func test_tc032_full_session_reaches_results() -> void:
	GameState.clear_session()
	GameFlow.open_current()
	await wait_physics_frames(5)
	assert_eq(_current().name, "PlayerSetup")
	_current().round_limit = 1
	_current().setup._on_start()
	await wait_physics_frames(2)
	_current().rules.ready_pressed.emit()
	await wait_physics_frames(5)
	for turn in 2:
		assert_eq(_current().name, "PlayerHandoff", "Handoff before trivia turn %d" % (turn + 1))
		GameFlow.start_activity()
		await wait_physics_frames(5)
		assert_eq(_current().name, "Trivia")
		var q = _current().question
		_current().screen._on_answer(q.get_correct_index())
		_current().screen.continue_pressed.emit()
		await wait_physics_frames(5)
	for turn in 2:
		assert_eq(_current().name, "PlayerHandoff", "Handoff before challenge %d" % (turn + 1))
		GameFlow.start_activity()
		await wait_physics_frames(5)
		assert_eq(_current().name, "Maze")
		_current()._start()
		_current()._on_finished(turn == 0, "test")
		_current().screen.result_continue_pressed.emit()
		await wait_physics_frames(5)
	assert_eq(_current().name, "Results", "Session ends on results")
	assert_eq(GameState.players[0].score, 10)
	assert_eq(GameState.players[1].score, 10)


## TC-033 (Integration): Play again starts a clean session at setup.
func test_tc033_play_again_resets() -> void:
	GameState.start_session(["Metal Core", "Solar Sail"], 1)
	GameState.players[0].score = 50
	GameFlow.reset_to_setup()
	await wait_physics_frames(5)
	assert_eq(_current().name, "PlayerSetup")
	assert_true(GameState.players.is_empty(), "No players carried over")
