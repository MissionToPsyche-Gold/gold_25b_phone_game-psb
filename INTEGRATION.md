main menu's Start Game button can call:

```gdscript
func _on_start_game_pressed() -> void:
    GameFlow.reset_to_setup()
```


Set `trivia_scene_path` in `controllers/game_controller.gd` to the real trivia scene path.


```gdscript
var attempt_token: String
var player_id: int

func _ready() -> void:
    attempt_token = GameState.get_attempt_token()
    player_id = GameState.current_player_id

func on_answer_checked(correct: bool) -> void:
    if GameState.record_trivia_result(attempt_token, correct):
        # Show your answer explanation here.
        # Save any data you need before recording: the current player may advance.
        pass

func on_feedback_continue_pressed() -> void:
    GameFlow.open_current()
```


```gdscript
if GameState.end_questions_exhausted():
    GameFlow.open_current()
```


Set `maze_scene_path` in `controllers/game_controller.gd` to the real maze scene path.

```gdscript
var attempt_token: String
var player_id: int

func _ready() -> void:
    attempt_token = GameState.get_attempt_token()
    player_id = GameState.current_player_id

func on_maze_completed(success: bool) -> void:
    var recovery = 1 if success else 0
    if GameState.record_maze_result(attempt_token, success, recovery):
        # Stop your timer/input and show your result here.
        pass

func on_result_continue_pressed() -> void:
    GameFlow.open_current()
```
