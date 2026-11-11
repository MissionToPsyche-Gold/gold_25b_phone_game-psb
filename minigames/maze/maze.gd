extends Control
## Maze minigame. Reach the goal before time runs out.
## Report rules: UF-8 / SF15 / SF16

signal finished(success: bool, detail: String)
signal time_changed(remaining: float, total: float)

const TIME_LIMIT := 30.0   # seconds (report SF16)


# Maze presets, randomly pick a preset according to difficulty/round

const EASY_MAZES := [
	[
		"#########",
		"#soooooo#",
		"#######o#",
		"#ooo#ooo#",
		"#o###o###",
		"#ooooooe#",
		"#########",
	],
	[
		"#########",
		"#soo#ooo#",
		"###o#o#o#",
		"#o#ooo#o#",
		"#o#####o#",
		"#ooooooe#",
		"#########",
	],
]

const MEDIUM_MAZES := [
	[
		"###########",
		"#soo#ooo#o#",
		"###o#o#o#o#",
		"#o#ooo#ooo#",
		"#o#######o#",
		"#ooo#ooooo#",
		"#o###o#####",
		"#ooooooooe#",
		"###########",
	],
	[
		"###########",
		"#s#ooooooo#",
		"#o###o###o#",
		"#o#ooo#ooo#",
		"#o#o###o###",
		"#ooo#o#o#o#",
		"#####o#o#o#",
		"#ooooooooe#",
		"###########",
	],
]

const HARD_MAZES := [
	[
		"#############",
		"#soooo#o#ooo#",
		"#####o#o#o#o#",
		"#ooo#o#ooo#o#",
		"#o#o#o#####o#",
		"#o#ooo#ooooo#",
		"#o#####o###o#",
		"#o#ooooo#o#o#",
		"#o###o###o#o#",
		"#ooooo#ooooe#",
		"#############",
	],
	[
		"#############",
		"#soo#ooo#ooo#",
		"###o#o#o###o#",
		"#ooo#o#ooo#o#",
		"#o###o###o#o#",
		"#ooooo#ooo#o#",
		"#######o###o#",
		"#ooooo#o#ooo#",
		"#o#####o###o#",
		"#ooooooooooe#",
		"#############",
	],
]

const ARROW_BUTTONS_HEIGHT := 130.0
const ARROW_SIZE := 56.0

#load icons for asteroid and Psyche (end) and Earth (start)
const SPACECRAFT := preload("res://assets/art/spacecraft.png")
const PSYCHE := preload("res://assets/art/psyche.png")
const EARTH := preload("res://assets/art/earth.png")

var _time_left := TIME_LIMIT
var _over := false

#maze layout dimensions
var _cols := 0
var _rows := 0
# Start and end
var _start := Vector2i.ZERO # start position
var _endgoal := Vector2i.ZERO # end position
var _player := Vector2i.ZERO # player position

var testing_hotkeys: bool = true
var maze_seed: int = 0

var _layout: Array = []
var _random := RandomNumberGenerator.new()

func _ready() -> void:
	# Build or set up your maze here: grid, walls, player, goal, arrow buttons.
	_choose_layout()
	_read_layout()
	_draw_arrow_keys()


# read LAYOUT, find dimensions, start, and endgoal positions, spawn player at start
func _read_layout() -> void:
	_rows = _layout.size() # num rows
	_cols = _layout[0].length() # num cols
	
	# now go through everything to find s (start) and e (endgoal)
	for y in range(_rows):
		for x in range(_cols):
			var ch: String = _layout[y][x]
			if ch == "s":
				_start = Vector2i(x,y)
			elif ch == "e":
				_endgoal = Vector2i(x,y)
	#set player to spawn at start
	_player = _start


# check if a wall. If true, can't go throgh it
func _check_wall(cell: Vector2i) -> bool:
	# check out of bounds
	if cell.x < 0 or cell.x >= _cols:
		return true
	if cell.y <0 or cell.y >= _rows:
		return true
	#now check in bounds if the char is a # it is a wall
	return _layout[cell.y][cell.x] == '#'

func _process(delta: float) -> void:
	if _over:
		return
	_time_left = maxf(0.0, _time_left - delta)
	time_changed.emit(_time_left, TIME_LIMIT)
	if _time_left <= 0.0:
		_end(false, "Out of time!")


## Call this when the player reaches the goal.
func _on_goal_reached() -> void:
	_end(true, "Reached the goal in %.1f seconds" % (TIME_LIMIT - _time_left))


func _end(success: bool, detail: String) -> void:
	if _over:
		return          # makes sure finished is only sent once
	_over = true
	set_process(false)
	finished.emit(success, detail)


# Rendering part

## get size of a square in the maze, so that it can fit and still leave space for buttons
# supports multiple layouts in the future of varying dimensions
func _square_size() -> float:
	var area := Vector2(size.x, size.y - ARROW_BUTTONS_HEIGHT)
	return floorf(minf(area.x/ _cols, area.y/_rows))

# now, define the start origin as the top left corner of the maze, and make it centered
func _origin()-> Vector2:
	var square := _square_size()
	var maze_pixels := Vector2(_cols * square, _rows * square) #dimensions of maze in pixels
	var area := Vector2(size.x, size.y - ARROW_BUTTONS_HEIGHT)
	return((area - maze_pixels) / 2.0).floor()

## Single grid square, as a rectangle
func _cell_rect(cell: Vector2i) -> Rect2:
	var square := _square_size()
	return Rect2(_origin() + Vector2(cell.x * square, cell.y * square), Vector2(square, square))

## now draw the maze
func _draw() -> void:
	#Squares are either a wall or a path
	for y in range(_rows):
		for x in range(_cols):
			var cell := Vector2i(x,y)
			var rect := _cell_rect(cell)
			
			if _check_wall(cell):
				draw_rect(rect, UIStyle.ORANGE) # wall
			else:
				draw_rect(rect, UIStyle.PANEL) # path
	# start (earth) and endgoal (psyche)
	draw_texture_rect(EARTH, _cell_rect(_start), false)
	draw_texture_rect(PSYCHE, _cell_rect(_endgoal), false)
	# now draw player
	draw_texture_rect(SPACECRAFT, _cell_rect(_player), false)
	

# MOVEMENT
func _move(direction: Vector2i) -> void:
	if _over:
		return #game ended, ignore input
	var next := _player + direction # cell requested to move to
	if _check_wall(next):
		return # trying to move into a wall, don't move at all
	_player = next # move player to next
	# after moving redraw
	queue_redraw()
	# Detect if end reached
	if _player == _endgoal:
		_on_goal_reached()

# arrow keys


# Draw the arrow keys
func _draw_arrow_keys() -> void:
	# box container to hold arrow keys
	var col := UIStyle.vbox(8)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	col.offset_top = -ARROW_BUTTONS_HEIGHT
	add_child(col)
	
	# ^ arrow key, row 1
	var top_row := UIStyle.hbox(8)
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	top_row.add_child(_arrow("^", Vector2i.UP))
	col.add_child(top_row)
	
	# < and V and > arrow keys, row 2
	# < key
	var mid_row := UIStyle.hbox(8)
	mid_row.alignment = BoxContainer.ALIGNMENT_CENTER
	mid_row.add_child(_arrow("<", Vector2i.LEFT))
	
	# V key
	mid_row.add_child(_arrow("V", Vector2i.DOWN))
	
	# > key
	mid_row.add_child(_arrow(">", Vector2i.RIGHT))
	col.add_child(mid_row)


# Arrow key that moves player in tapped direction
func _arrow(text: String, direction: Vector2i) -> Button:
	var button := UIStyle.button(text, "Cyan", int(ARROW_SIZE))
	button.custom_minimum_size = Vector2(ARROW_SIZE, ARROW_SIZE)
	button.pressed.connect(func(): _move(direction))
	return button

func _choose_layout() -> void:
	if maze_seed == 0:
		_random.randomize()
	else:
		_random.seed = maze_seed

	var current_round: int = maxi(1, GameState.round_number)
	var selection: Array
	var difficulty: String

	if current_round == 1:
		selection = EASY_MAZES
		difficulty = "Easy"
	elif current_round == 2:
		selection = MEDIUM_MAZES
		difficulty = "Medium"
	else:
		selection = HARD_MAZES
		difficulty = "Hard"

	var selected: int = _random.randi_range(0, selection.size() - 1)
	_layout = selection[selected]

	print("Maze: round %d, difficulty: %s, preset: %d" % [current_round, difficulty, selected + 1])



# for speeding up demo, force win or force fail.
func _input(event: InputEvent) -> void:
	if not testing_hotkeys or _over:
		return

	if event is InputEventKey:
		if not event.pressed or event.echo:
			return

		if event.keycode == KEY_F:
			get_viewport().set_input_as_handled()
			_end(false, "demo forced maze fail.")

		elif event.keycode == KEY_W:
			get_viewport().set_input_as_handled()
			_end(true, "demo forced maze complete.")
