extends Control
## GameFlow "trivia" phase (res://scenes/trivia.tscn).
## Themed trivia turn using the attempt-token pattern from INTEGRATION.md.
## Questions come from the placeholder QuestionBank autoload; the trivia
## teammate can swap in their own question logic here (see docs/UI_GUIDE.md).

var screen: TriviaScreen
var pause: PauseOverlay
var attempt_token: String
var player            # PsychePlayer
var question: Dictionary
var round_number := 1


func _ready() -> void:
	if GameState.phase != "trivia":
		GameFlow.open_current()
		return
	Backdrop.use_game_layout()
	attempt_token = GameState.get_attempt_token()
	player = GameState.current_player()
	round_number = GameState.round_number
	question = QuestionBank.next_question()
	if question.is_empty():
		if GameState.end_questions_exhausted():
			GameFlow.open_current()
		return
	screen = TriviaScreen.new()
	add_child(screen)
	pause = PauseOverlay.new()
	pause.visible = false
	add_child(pause)
	screen.answer_selected.connect(_on_answer)
	screen.continue_pressed.connect(GameFlow.open_current)
	screen.pause_pressed.connect(pause.open)
	pause.resume_pressed.connect(func(): pause.visible = false)
	pause.quit_pressed.connect(GameStateUI.quit_to_menu)
	screen.show_question(GameStateUI.player_dict(player), round_number, str(question.question), question.choices)
	screen.on_shown()


func _on_answer(index: int) -> void:
	var correct_index := int(question.correct_index)
	var before_score: int = player.score
	var before_lives: int = player.lives
	# Save what we need first: recording advances GameState to the next player.
	if not GameState.record_trivia_result(attempt_token, index == correct_index):
		return
	screen.show_feedback(correct_index, index, str(question.get("explanation", "")),
		GameStateUI.player_dict(player), player.score - before_score, player.lives - before_lives)
