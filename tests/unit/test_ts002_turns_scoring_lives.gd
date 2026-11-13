extends GutTest
## TS-002: Turns, Scoring and Lives (GameState model)
## Requirements: UF-3, UF-5, UF-7, SF05, SF06, SF13, SF14, SF22-SF24, UC-2..UC-4


func before_each() -> void:
	GameState.clear_session()
	GameState.start_session(["Ada", "Sam", "Kai"], 0)
	GameState.begin_activity()   # handoff -> trivia for player 1


func after_each() -> void:
	GameState.clear_session()


## TC-006 (Unit): a correct answer adds 10 points once; reusing the attempt is ignored.
func test_tc006_correct_answer_scores_once() -> void:
	var token := GameState.get_attempt_token()
	var p = GameState.current_player()
	assert_true(GameState.record_trivia_result(token, true))
	assert_eq(p.score, 10, "Correct answer = +10")
	assert_false(GameState.record_trivia_result(token, true), "Same attempt cannot be recorded twice")
	assert_eq(p.score, 10, "Score unchanged by a repeated tap")


## TC-007 (Unit): a wrong answer costs exactly one life and no points.
func test_tc007_wrong_answer_costs_life() -> void:
	var p = GameState.current_player()
	GameState.record_trivia_result(GameState.get_attempt_token(), false)
	assert_eq(p.lives, 2, "3 -> 2 lives")
	assert_eq(p.score, 0, "No points for a wrong answer")


## TC-008 (Unit): players with 0 lives are skipped in the turn order.
func test_tc008_eliminated_player_skipped() -> void:
	GameState.players[1].lives = 0
	GameState.record_trivia_result(GameState.get_attempt_token(), true)   # Ada answers
	assert_eq(GameState.current_player().player_name, "Kai", "Sam is out, so Kai is next")


## TC-009 (Unit): the game ends with results when one or no players have lives left.
func test_tc009_game_ends_with_one_survivor() -> void:
	GameState.players[1].lives = 0
	GameState.players[2].lives = 0
	GameState.players[0].lives = 1
	GameState.record_trivia_result(GameState.get_attempt_token(), false)   # Ada loses her last life
	assert_eq(GameState.phase, "results", "No survivors -> results")
