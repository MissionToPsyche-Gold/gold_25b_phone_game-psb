extends GutTest
## TS-004: Trivia Screen
## Requirements: UF-4, UF-6, UF-7, SF08, SF11-SF14, SP03

const PLAYER := {"id": 0, "name": "Metal Core", "score": 10, "lives": 3}
const CHOICES := ["1852", "1969", "2023", "2029"]

var screen: TriviaScreen


func before_each() -> void:
	screen = TriviaScreen.new()
	add_child_autofree(screen)
	screen.show_question(PLAYER, 1, "When was Psyche discovered?", CHOICES)


## TC-015 (Unit): only the first answer tap is reported.
func test_tc015_first_tap_only() -> void:
	watch_signals(screen)
	screen._on_answer(0)
	screen._on_answer(2)
	screen._on_answer(0)
	assert_signal_emit_count(screen, "answer_selected", 1)
	assert_eq(get_signal_parameters(screen, "answer_selected")[0], 0)


## TC-016 (Unit): feedback shows right/wrong, the correct answer and the explanation.
func test_tc016_feedback_shows_answer_and_explanation() -> void:
	screen._on_answer(1)
	var after := PLAYER.duplicate()
	after.lives = 2
	screen.show_feedback(0, 1, "Discovered in 1852 by Annibale de Gasparis.", after, 0, -1)
	assert_true(screen._feedback.visible, "Feedback panel visible")
	assert_eq(screen._fb_title.text, "Not quite")
	assert_string_contains(screen._fb_answer.text, "1852")
	assert_string_contains(screen._fb_explain.text, "Annibale de Gasparis")


## TC-017 (Unit): a question picture is shown when the question has one and
## hidden when it doesn't.
func test_tc017_question_image_shown_only_when_present() -> void:
	assert_true(screen.has_method("set_question_image"), "TriviaScreen should have set_question_image()")
	if not screen.has_method("set_question_image"):
		return
	var img := Image.create_empty(8, 8, false, Image.FORMAT_RGBA8)
	screen.set_question_image(ImageTexture.create_from_image(img))
	assert_true(screen.question_image.visible, "Image visible when provided")
	screen.set_question_image(null)
	assert_false(screen.question_image.visible, "Image hidden when absent")
