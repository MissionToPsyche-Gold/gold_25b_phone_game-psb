# Plugging your part into the themed UI

The game state teammate's `GameState` and `GameFlow` are unchanged. Two lines in `controllers/game_controller.gd` now point at the themed scenes:

```gdscript
var trivia_scene_path: String = "res://scenes/trivia.tscn"
var maze_scene_path: String = "res://scenes/maze.tscn"
```

`INTEGRATION.md` (the attempt-token pattern) still applies. The themed scenes already follow it, so most teammates can plug in without writing any UI.

---

## Trivia teammate

`scenes/trivia.tscn` (script `scripts/scenes/trivia_scene.gd`) already does the full turn: token, HUD, question, first-tap-only answer, `GameState.record_trivia_result`, feedback with explanation, and Continue to `GameFlow.open_current()`.

The only placeholder part is **where questions come from**: the `QuestionBank` autoload, which reads `data/sample_questions.json` and never repeats a question in a session. You have two options:

- **Easy:** keep `QuestionBank` and replace `data/sample_questions.json` with the real sponsor-approved bank. The format is report SD03/SD05:
  ```json
  {"id": "q-17", "question": "...", "choices": ["A", "B", "C", "D"], "correct_index": 2, "explanation": "..."}
  ```
  Invalid records are skipped with a warning.
- **Your own logic:** replace the `QuestionBank.next_question()` call in `trivia_scene.gd` with yours. It needs to return a Dictionary with the keys above, or `{}` when no questions are left; the scene then calls `GameState.end_questions_exhausted()`.

If you'd rather build your own trivia scene, reuse the screen so it still matches:

```gdscript
var screen := TriviaScreen.new()
add_child(screen)
screen.show_question(GameStateUI.player_dict(player), GameState.round_number, text, choices)
screen.answer_selected.connect(func(i): ...)   # fires once
screen.show_feedback(correct_index, i, explanation, GameStateUI.player_dict(player), score_delta, lives_delta)
screen.continue_pressed.connect(GameFlow.open_current)
```

---

## Maze / minigame teammate

`scenes/maze.tscn` is a frame: an intro card, then **your minigame inside a box with a countdown bar**, then a result card. It records the result with `GameState.record_maze_result` and returns to `GameFlow`.

Make your maze a scene whose **root is a Control** (it's sized to fill the box) with these signals:

```gdscript
extends Control

signal finished(success: bool, detail: String)          # required, emit once
signal time_changed(remaining: float, total: float)     # optional: drives the countdown bar

const TIME_LIMIT := 30.0   # report UF-8 / SF16
var _left := TIME_LIMIT
var _over := false

func _process(delta: float) -> void:
	if _over:
		return
	_left -= delta
	time_changed.emit(_left, TIME_LIMIT)
	if _left <= 0.0:
		_over = true
		finished.emit(false, "Out of time!")

func _on_goal_reached() -> void:
	if _over:
		return
	_over = true
	finished.emit(true, "Reached the goal in %.1f s" % (TIME_LIMIT - _left))
```

Then open `scenes/maze.tscn`, select the **Maze** root node, and drag your scene into **Minigame Scene** in the Inspector. That's all. Leave it empty to use the tap placeholder.

Tips so it matches the rest of the game:
- Use `UIStyle` colors (`UIStyle.CYAN`, `UIStyle.ORANGE`, ...) and `UIStyle.button(...)` / `UIStyle.label(...)`.
- Touch only (report SO06): use on-screen arrow buttons or swipes, at least 44 × 44 px.
- No shooting or violence (EC-2 / SE06).
- Show any instructions as text (SP03). `TimerBar` already shows seconds in text.
- Check `GameSettings.reduce_motion` before adding screen shake or flashing.

**More minigames later** (Memory Tiles, Sequence Memory, Reaction Speed): once `GameState` adds a phase for one (for example `"memory_tiles"`):
1. Duplicate `scenes/maze.tscn`, set its **Activity** to that phase name, and set **Minigame Scene** to the new game.
2. Add an entry for it in `GameStateUI.MINIGAMES` (`scripts/scenes/game_state_ui.gd`) with its title, how-to text, time and reward text.
3. Point `GameFlow` at the new scene.

The scene currently records results with `record_maze_result`. A new phase needs the matching `GameState` function; ask the game state teammate.

---

## Game state teammate

Nothing in `models/` was changed. Notes:
- The UI reads `players`, `current_player()`, `round_number`, `next_activity`, `phase`, `leaderboard()` and `end_reason`, and calls only your public functions.
- `tests/smoke.gd`: your model checks are untouched; the scene half was updated for the new scene structure. It passes (125 checks, 0 failures).
- The setup scene calls `start_session(names, 0)`, so there's no round limit (see README, "Things the team should decide").
