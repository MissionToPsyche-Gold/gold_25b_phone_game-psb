extends GutTest
## TS-003: Trivia Question Bank
## Requirements: UF-4, UF-5, SF07, SF09, SF10, SD03, SD05, EC-1

const DATA_PATH := "res://data/trivia.json"
const QUESTION_SCRIPT := "res://models/trivia_question.gd"


func before_each() -> void:
	for q in QuestionBank.questions:
		q.asked = false


func _raw_questions() -> Array:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	assert_not_null(f, "trivia.json should open")
	return JSON.parse_string(f.get_as_text()) if f else []


## TC-010 (Unit): every question in the bank is well formed: text, exactly 4
## different answers, a correct index 0-3, an explanation and a difficulty.
func test_tc010_question_data_is_valid() -> void:
	var data := _raw_questions()
	assert_gt(data.size(), 0, "Bank is not empty")
	var ids := {}
	for q: Dictionary in data:
		var label := "question %s" % str(q.get("id", "?"))
		assert_false(ids.has(q.id), "Unique id: " + label)
		ids[q.id] = true
		assert_ne(str(q.get("question", "")).strip_edges(), "", "Has text: " + label)
		var answers: Array = q.get("answers", [])
		assert_eq(answers.size(), 4, "4 answers: " + label)
		var distinct := {}
		for a in answers:
			distinct[str(a).strip_edges().to_lower()] = true
		assert_eq(distinct.size(), answers.size(), "Answers are all different: " + label)
		assert_between(int(q.get("correct answer", -1)), 0, 3, "Correct index 0-3: " + label)
		assert_ne(str(q.get("explanation", "")).strip_edges(), "", "Has explanation: " + label)
		assert_has(["Easy", "Medium", "Hard"], q.get("difficulty", ""), "Known difficulty: " + label)


## TC-011 (Unit): no question is asked twice in the same session.
func test_tc011_no_repeats_in_session() -> void:
	var seen := {}
	for i in QuestionBank.questions.size():
		var q = QuestionBank.next_question(0)
		if q == null:
			break
		assert_false(seen.has(q.id), "Question %d repeated" % q.id)
		seen[q.id] = true
	assert_gt(seen.size(), 0)


## TC-012 (Unit): when every question of the player's difficulty is used, the
## bank serves a question of another difficulty instead of ending the game.
func test_tc012_falls_back_to_other_difficulty() -> void:
	for q in QuestionBank.questions:
		if q.get_difficulty() == "Easy":
			q.asked = true
	var q = QuestionBank.next_question(0)   # score 0 -> wants Easy
	assert_not_null(q, "Medium/Hard questions remain, so a question must be returned")


## TC-013 (Unit): a question may name an optional image; questions without one
## report no image.
func test_tc013_optional_question_image() -> void:
	var base := {"id": 900, "difficulty": "Easy", "question": "Q?", "correct answer": 0,
		"answers": ["a", "b", "c", "d"], "explanation": "e"}
	var plain = TriviaQuestion.new(base)
	assert_true(plain.has_method("has_image"), "TriviaQuestion should have has_image()")
	if not plain.has_method("has_image"):
		return
	assert_false(plain.has_image(), "No image field -> no image")
	var with_image := base.duplicate()
	with_image["image"] = "res://assets/questions/psyche_shape.png"
	var q = TriviaQuestion.new(with_image)
	assert_true(q.has_image())
	assert_eq(q.get_image_path(), "res://assets/questions/psyche_shape.png")


## TC-014 (Unit): a malformed question record is rejected instead of crashing.
func test_tc014_malformed_record_rejected() -> void:
	var script: Script = load(QUESTION_SCRIPT)
	var names := script.get_script_method_list().map(func(m): return m.name)
	assert_has(names, "is_valid_record", "TriviaQuestion should have is_valid_record()")
	if not names.has("is_valid_record"):
		return
	var bad := [
		{"id": 1, "question": "No answers", "correct answer": 0, "explanation": "x", "difficulty": "Easy"},
		{"id": 2, "question": "Three answers", "answers": ["a", "b", "c"], "correct answer": 0, "explanation": "x", "difficulty": "Easy"},
		{"id": 3, "question": "", "answers": ["a", "b", "c", "d"], "correct answer": 0, "explanation": "x", "difficulty": "Easy"},
		{"id": 4, "question": "Bad index", "answers": ["a", "b", "c", "d"], "correct answer": 7, "explanation": "x", "difficulty": "Easy"},
	]
	for d in bad:
		assert_false(script.call("is_valid_record", d), "Record %d should be rejected" % d.id)
	var good := {"id": 5, "question": "Fine", "answers": ["a", "b", "c", "d"], "correct answer": 2, "explanation": "x", "difficulty": "Hard"}
	assert_true(script.call("is_valid_record", good), "Valid record accepted")
