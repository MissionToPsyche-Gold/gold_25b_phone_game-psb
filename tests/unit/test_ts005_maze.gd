extends GutTest
## TS-005: Maze Minigame
## Requirements: UF-8, UF-11, SF15, SF16, SE07, UC-5

const MAZE_SCENE := "res://minigames/maze/maze.tscn"
const MAZE_SCRIPT := "res://minigames/maze/maze.gd"


func _maze(seed := 0):
	var holder := Control.new()
	holder.size = Vector2(330, 450)   # the play area on a small phone
	add_child_autofree(holder)
	var m = load(MAZE_SCENE).instantiate()
	m.maze_seed = seed
	holder.add_child(m)
	return m


func after_each() -> void:
	GameState.clear_session()


func _solvable(layout: Array) -> bool:
	var start := Vector2i(-1, -1)
	var goal := Vector2i(-1, -1)
	for y in layout.size():
		for x in layout[y].length():
			if layout[y][x] == "s":
				start = Vector2i(x, y)
			elif layout[y][x] == "e":
				goal = Vector2i(x, y)
	if start.x < 0 or goal.x < 0:
		return false
	var seen := {start: true}
	var queue := [start]
	while not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		if c == goal:
			return true
		for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var n: Vector2i = c + d
			if n.y >= 0 and n.y < layout.size() and n.x >= 0 and n.x < layout[n.y].length() \
					and layout[n.y][n.x] != "#" and not seen.has(n):
				seen[n] = true
				queue.append(n)
	return false


## TC-018 (Unit): every preset maze has a start, a goal and a path between them.
func test_tc018_all_presets_solvable() -> void:
	var consts: Dictionary = load(MAZE_SCRIPT).get_script_constant_map()
	var count := 0
	for set_name in ["EASY_MAZES", "MEDIUM_MAZES", "HARD_MAZES"]:
		for i in consts[set_name].size():
			assert_true(_solvable(consts[set_name][i]), "%s #%d is solvable" % [set_name, i + 1])
			count += 1
	assert_eq(count, 12, "4 presets per difficulty")


## TC-019 (Unit): moving into a wall leaves the spacecraft where it is.
func test_tc019_wall_blocks_movement() -> void:
	var m = _maze()
	m._layout = ["#####", "#s#e#", "#ooo#", "#####"]
	m._read_layout()
	m._move(Vector2i.RIGHT)   # wall
	assert_eq(m._player, Vector2i(1, 1), "Blocked by wall")
	m._move(Vector2i.DOWN)    # open
	assert_eq(m._player, Vector2i(1, 2), "Moved into open cell")


## TC-020 (Unit): reaching the goal finishes the maze as a win exactly once.
func test_tc020_goal_wins_once() -> void:
	var m = _maze()
	m._layout = ["####", "#se#", "####"]
	m._read_layout()
	watch_signals(m)
	m._move(Vector2i.RIGHT)
	m._move(Vector2i.LEFT)
	m._move(Vector2i.RIGHT)
	assert_signal_emit_count(m, "finished", 1)
	assert_true(get_signal_parameters(m, "finished")[0], "Result is a win")


## TC-021 (Unit): running out of the 30-second limit finishes the maze as a loss.
func test_tc021_timeout_loses() -> void:
	var m = _maze()
	watch_signals(m)
	m._process(31.0)
	assert_signal_emit_count(m, "finished", 1)
	assert_false(get_signal_parameters(m, "finished")[0], "Result is a loss")


## TC-022 (Unit): round 1 uses an easy maze, round 3+ a hard one, and the same
## seed always picks the same maze (SE07 repeatable tests).
func test_tc022_difficulty_by_round_and_seeded() -> void:
	var consts: Dictionary = load(MAZE_SCRIPT).get_script_constant_map()
	GameState.round_number = 1
	assert_has(consts.EASY_MAZES, _maze(7)._layout, "Round 1 -> easy")
	GameState.round_number = 3
	assert_has(consts.HARD_MAZES, _maze(7)._layout, "Round 3 -> hard")
	assert_eq(_maze(42)._layout, _maze(42)._layout, "Same seed -> same maze")
