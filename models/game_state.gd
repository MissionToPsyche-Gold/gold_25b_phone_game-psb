extends Node
signal state_changed
const PlayerData = preload("res://models/player.gd")
const STARTING_LIVES: int = 3
const MAX_LIVES: int = 3
const CORRECT_ANSWER_POINTS: int = 10
const MAZE_RECOVERY: int = 1
const DEFAULT_DEMO_ROUNDS: int = 3

var players: Array = []
var round_number: int = 1
var max_rounds: int = DEFAULT_DEMO_ROUNDS  # 0 = no round limit
var phase: String = "setup"  # setup / handoff / trivia / maze / results
var next_activity: String = "trivia"
var current_player_id: int = -1
var end_reason: String = ""
var event_log: Array = []
var _queue: Array = []
var _queue_index: int = 0
var _session_serial: int = 0
var _attempt_serial: int = 0
var _active_token: String = ""
var _processed_tokens: Dictionary = {}

func validate_names(names: Array) -> String:
	if names.size() < 2 or names.size() > 4:
		return "Select 2, 3, or 4 players."
	for i in range(names.size()):
		var value = str(names[i]).strip_edges()
		if value.is_empty():
			return "Enter a name for Player %d." % (i + 1)
		if value.length() > 20:
			return "Player %d's name must be 20 characters or fewer." % (i + 1)
	return ""

func start_session(names: Array, rounds: int = DEFAULT_DEMO_ROUNDS) -> String:
	var error = validate_names(names)
	if not error.is_empty():
		return error
	if rounds < 0:
		return "The round limit cannot be negative."
	clear_session()
	_session_serial += 1
	max_rounds = rounds
	for i in range(names.size()):
		players.append(PlayerData.new(i, str(names[i]).strip_edges(), STARTING_LIVES))
	_begin_round()
	return ""

func clear_session() -> void:
	players.clear()
	_queue.clear()
	_processed_tokens.clear()
	event_log.clear()
	_attempt_serial = 0
	_active_token = ""
	current_player_id = -1
	round_number = 1
	phase = "setup"
	next_activity = "trivia"
	end_reason = ""
	state_changed.emit()

func get_player(player_id: int):
	for player in players:
		if player.id == player_id:
			return player
	return null

func current_player():
	return get_player(current_player_id)

func eligible_ids() -> Array:
	var ids: Array = []
	for player in players:
		if not player.is_eliminated():
			ids.append(player.id)
	return ids

func _begin_round() -> void:
	_queue = eligible_ids()
	_queue_index = 0
	next_activity = "trivia"
	_prepare_handoff()

func _prepare_handoff() -> void:
	if _check_elimination_end():
		return
	while _queue_index < _queue.size():
		var player = get_player(_queue[_queue_index])
		if player != null and not player.is_eliminated():
			current_player_id = player.id
			phase = "handoff"
			state_changed.emit()
			return
		_queue_index += 1
	if next_activity == "trivia":
		# All eligible players finish trivia before the maze round starts.
		next_activity = "maze"
		_queue = eligible_ids()
		_queue_index = 0
		_prepare_handoff()
	else:
		if max_rounds > 0 and round_number >= max_rounds:
			_finish("Demo round limit reached")
		else:
			round_number += 1
			_begin_round()

func begin_activity() -> String:
	if phase != "handoff":
		return ""
	phase = next_activity
	_attempt_serial += 1
	_active_token = "%d:%d:%d:%s" % [_session_serial, _attempt_serial, current_player_id, phase]
	state_changed.emit()
	return _active_token

func get_attempt_token() -> String:
	return _active_token

func record_trivia_result(token: String, correct: bool) -> bool:
	if not _valid_result(token, "trivia"):
		return false
	var player = current_player()
	if correct:
		player.score += CORRECT_ANSWER_POINTS
	else:
		player.lives = maxi(0, player.lives - 1)
	_record(token, "trivia", correct, 0)
	return true

func record_maze_result(token: String, success: bool, requested_recovery: int = MAZE_RECOVERY) -> bool:
	if not _valid_result(token, "maze"):
		return false
	var player = current_player()
	var previous_lives: int = player.lives
	if success:
		player.lives = mini(MAX_LIVES, player.lives + clampi(requested_recovery, 0, MAZE_RECOVERY))
	_record(token, "maze", success, player.lives - previous_lives)
	return true

func _valid_result(token: String, expected_phase: String) -> bool:
	return not token.is_empty() and token == _active_token and phase == expected_phase and not _processed_tokens.has(token)

func _record(token: String, activity: String, success: bool, recovered: int) -> void:
	var player = current_player()
	_processed_tokens[token] = true
	event_log.append({"token": token, "player_id": player.id, "round": round_number, "activity": activity, "success": success, "score": player.score, "lives": player.lives, "recovered": recovered})
	_active_token = ""
	_queue_index += 1
	_prepare_handoff()

func end_questions_exhausted() -> bool:
	if phase != "trivia":
		return false
	_active_token = ""
	_finish("No unused trivia questions remain")
	return true

func _check_elimination_end() -> bool:
	if not players.is_empty() and eligible_ids().size() <= 1:
		_finish("One player remains" if eligible_ids().size() == 1 else "No players remain")
		return true
	return false

func _finish(reason: String) -> void:
	phase = "results"
	end_reason = reason
	_active_token = ""
	state_changed.emit()

func leaderboard() -> Array:
	var rows: Array = []
	for player in players:
		rows.append({"id": player.id, "name": player.player_name, "score": player.score, "lives": player.lives, "eliminated": player.is_eliminated()})
	rows.sort_custom(func(a, b):
		if a.eliminated != b.eliminated:
			return not a.eliminated
		if a.score != b.score:
			return a.score > b.score
		if a.lives != b.lives:
			return a.lives > b.lives
		return a.id < b.id)
	var last_key = ""
	var rank_value = 0
	for i in range(rows.size()):
		var key = "%s:%d:%d" % [rows[i].eliminated, rows[i].score, rows[i].lives]
		if key != last_key:
			rank_value = i + 1
		rows[i]["rank"] = rank_value
		last_key = key
	return rows

func winners() -> Array:
	var rows = leaderboard()
	return rows.filter(func(row): return row.rank == 1 and not row.eliminated)
