class_name GameStateUI
extends RefCounted
## Helpers that translate the team's GameState (models/game_state.gd) into
## what the UI screens display. The UI never changes GameState itself except
## through GameState's own functions.

const MENU_SCENE := "res://scenes/main_menu.tscn"

## Display text for each minigame activity. When a new minigame is added to
## GameState (e.g. "memory_tiles"), add its entry here.
const MINIGAMES := {
	"maze": {
		"title": "Maze",
		"how": "Guide the spacecraft through the maze to the goal before time runs out. Bumping a wall won't move you.",
		"time_text": "30 seconds",
		"seconds": 30.0,
		"reward_text": "Win: +1 life",
	},
}


## PsychePlayer -> {"id","name","score","lives"} used by every screen.
static func player_dict(p) -> Dictionary:
	if p == null:
		return {"id": 0, "name": "Player", "score": 0, "lives": 0}
	return {"id": p.id, "name": p.player_name, "score": p.score, "lives": p.lives}


static func activity_text(activity: String) -> String:
	if activity == "trivia":
		return "Next: Psyche trivia question"
	var info: Dictionary = MINIGAMES.get(activity, {"title": activity.capitalize()})
	return "Next: Bonus challenge - %s" % info.title


## End the session and go back to the title screen.
static func quit_to_menu() -> void:
	GameState.clear_session()
	SceneTransition.change_scene(MENU_SCENE)
