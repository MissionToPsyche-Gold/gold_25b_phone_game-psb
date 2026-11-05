extends Node
## Autoload "QuestionBank" - PLACEHOLDER so the themed trivia scene works now.
## The trivia teammate can replace this with their own question handling.
##   - loads data/sample_questions.json
##   - keeps only valid questions: id, text, 4 choices, correct_index 0-3 (SD03)
##   - never repeats a question within a session (UF-5, SF09, SF10)
##   - forgets used questions when GameState starts a new session

const QUESTIONS_PATH := "res://data/trivia.json"

var questions: Array = []

func _ready() -> void:
	_load()
	GameState.state_changed.connect(func():
		if GameState.phase == "setup":
			questions.clear()
			_load())


## Returns {} when every question has been used.
func next_question() -> TriviaQuestion:
	var pool := questions.filter(func(q): return not q._used())
	if pool.is_empty():
		return 
	var q: TriviaQuestion = pool.pick_random()
	q.set_used()
	return q


func _load() -> Array:
	var f := FileAccess.open(QUESTIONS_PATH, FileAccess.READ)
	
	if f == null:
		push_error("QuestionBank: can't open " + QUESTIONS_PATH)
		return []
		
	var text = f.get_as_text()
	f.close()
	
	var json = JSON.new()
	var error = json.parse(text)
	
	if error != OK:
		push_error("QuestionBank: invalid JSON in " + QUESTIONS_PATH)
		return questions

	var data: Array = json.data

	for question in data:
		var trivia_question = TriviaQuestion.new(question)
		questions.append(trivia_question)
		
	return questions
