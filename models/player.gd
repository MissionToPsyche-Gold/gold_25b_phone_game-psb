class_name PsychePlayer
extends RefCounted
## Data for one participant. IDs, rather than names, identify players.
var id: int
var player_name: String
var score: int = 0
var lives: int

func _init(player_id: int, display_name: String, starting_lives: int) -> void:
	id = player_id
	player_name = display_name
	lives = starting_lives

func is_eliminated() -> bool:
	return lives <= 0
