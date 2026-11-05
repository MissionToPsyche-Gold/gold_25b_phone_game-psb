extends SceneTree
var failures = 0
var checks = 0
var state
var flow

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func settle() -> void:
	for i in range(5):
		await process_frame

func run() -> void:
	state = root.get_node("GameState")
	flow = root.get_node("GameFlow")
	check(not state.start_session(["A"]).is_empty(), "Reject 1 player")
	check(not state.start_session(["A","B","C","D","E"]).is_empty(), "Reject 5 players")
	check(not state.start_session([" ","B"]).is_empty(), "Reject blank names")
	check(not state.start_session(["x".repeat(21),"B"]).is_empty(), "Reject long name")
	for count in range(2,5):
		var names: Array = []
		for i in range(count): names.append("Same name")
		check(state.start_session(names,1).is_empty(), "Accept %d players" % count)
		check(state.players.size() == count, "Correct player records")
		for i in range(count):
			check(state.current_player_id == i and state.next_activity == "trivia", "Trivia turn order")
			var token: String = state.begin_activity()
			check(state.record_trivia_result(token,true), "Accept trivia result")
			check(not state.record_trivia_result(token,true), "Reject duplicate trivia result")
			check(state.players[i].score == 10, "Score changes once")
		for i in range(count):
			check(state.current_player_id == i and state.next_activity == "maze", "Maze follows full trivia round")
			var token: String = state.begin_activity()
			check(not state.record_trivia_result(token,true), "Reject wrong result type")
			check(state.record_maze_result(token,true,100), "Accept maze result")
			check(state.players[i].lives == 3, "Life recovery capped")
			check(not state.record_maze_result(token,true), "Reject duplicate maze result")
		check(state.phase == "results", "Round limit ends session")
		check(state.winners().size() == count, "Tied players share winner rank")
	# Wrong trivia loses a life and a successful maze restores it once.
	state.start_session(["A","B"],0)
	var stale: String = state.begin_activity()
	state.record_trivia_result(stale,false)
	state.record_trivia_result(state.begin_activity(),true)
	check(state.players[0].lives == 2, "Wrong answer loses a life")
	state.record_maze_result(state.begin_activity(),true)
	check(state.players[0].lives == 3, "Successful maze restores one life")
	state.record_maze_result(state.begin_activity(),false)
	check(state.phase == "handoff" and state.round_number == 2, "Unlimited rounds advance")
	state.start_session(["A","B","C"],0)
	check(not state.record_trivia_result(stale,true), "Previous session token rejected")
	state.players[0].lives = 1
	state.record_trivia_result(state.begin_activity(),false)
	check(state.players[0].lives == 0, "Lives never negative")
	check(state.current_player_id == 1, "Next eligible player selected")
	state.record_trivia_result(state.begin_activity(),true)
	state.record_trivia_result(state.begin_activity(),true)
	check(state.current_player_id == 1 and state.next_activity == "maze", "Eliminated player skipped for maze")
	state.record_maze_result(state.begin_activity(),false)
	state.record_maze_result(state.begin_activity(),false)
	check(state.current_player_id == 1 and state.next_activity == "trivia", "Eliminated player skipped next round")
	state.start_session(["A","B"],0)
	state.players[0].lives = 1
	state.record_trivia_result(state.begin_activity(),false)
	check(state.phase == "results" and state.winners()[0].id == 1, "Last survivor wins")
	state.start_session(["A","B"],0)
	state.begin_activity()
	check(state.end_questions_exhausted() and state.phase == "results", "Question exhaustion ends session")
	state.clear_session()
	check(state.phase == "setup" and state.players.is_empty() and state.event_log.is_empty(), "Reset clears state")
	# Real scene loading and controls (updated for the themed UI scenes).
	flow.open_current()
	await settle()
	check(current_scene.name == "PlayerSetup", "Setup scene opens")
	var setup = current_scene.setup
	check(not setup._rows[2].visible, "Two fields by default")
	setup._on_start()
	check(setup._errors[0].visible, "Validation error shown")
	setup._fields[0].text = "Ada"
	setup._fields[1].text = "Sam"
	current_scene.round_limit = 1
	setup._on_start()
	check(current_scene.rules.visible, "Rules shown after valid setup")
	current_scene.rules.ready_pressed.emit()
	await settle()
	check(current_scene.name == "PlayerHandoff", "Handoff scene opens")
	flow.open_leaderboard()
	await settle()
	check(current_scene.name == "Leaderboard", "Leaderboard opens")
	check(current_scene.get_child(0)._list.get_child_count() == 2, "Leaderboard displays all players")
	flow.close_leaderboard()
	await settle()
	flow.start_activity()
	await settle()
	check(current_scene.name == "Trivia", "Trivia scene opens")
	var q = current_scene.question
	current_scene.screen._on_answer(int(q.correct_index))
	check(current_scene.screen._feedback.visible, "Answer feedback shown")
	check(state.players[0].score == 10, "Correct answer recorded once")
	current_scene.screen._on_answer(int(q.correct_index))
	check(state.players[0].score == 10, "Second tap ignored")
	current_scene.screen.continue_pressed.emit()
	await settle()
	flow.start_activity()
	await settle()
	q = current_scene.question
	current_scene.screen._on_answer((int(q.correct_index) + 1) % 4)
	check(state.players[1].lives == 2, "Wrong answer costs a life")
	current_scene.screen.continue_pressed.emit()
	await settle()
	flow.start_activity()
	await settle()
	check(current_scene.name == "Maze", "Maze scene opens")
	current_scene._start()
	current_scene._on_finished(true, "test")
	check(current_scene.screen._result.visible, "Minigame result shown")
	current_scene.screen.result_continue_pressed.emit()
	await settle()
	flow.start_activity()
	await settle()
	current_scene._start()
	current_scene._on_finished(false, "test")
	current_scene.screen.result_continue_pressed.emit()
	await settle()
	check(current_scene.name == "Results", "Results scene opens")
	await settle()
	check(current_scene.get_child(0)._list.get_child_count() == 2, "Results include every player")
	flow.reset_to_setup()
	await settle()
	check(current_scene.name == "PlayerSetup" and state.players.is_empty(), "Replay returns to clean setup")
	print("CHECKS: %d | FAILURES: %d" % [checks,failures])
	quit(0 if failures == 0 else 1)
