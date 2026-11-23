extends Node
## Autoload "QuestionBank": serves trivia questions from data/trivia.json.
##   - skips malformed records instead of crashing (SD03, test TC-014)
##   - never repeats a question within a session (UF-5, SF09, SF10, TC-011)
##   - picks difficulty from the player's score; if that difficulty has run
##     out, falls back to the nearest one that still has questions (TC-012)
##   - forgets used questions when GameState starts a new session

## Order to try when the preferred difficulty has no unused questions left.
const FALLBACK := {
	"Easy": ["Easy", "Medium", "Hard"],
	"Medium": ["Medium", "Easy", "Hard"],
	"Hard": ["Hard", "Medium", "Easy"],
}

const QUESTIONS_PATH := "res://data/trivia.json"

var questions: Array = []

func _ready() -> void:
	_load()
	GameState.state_changed.connect(func():
		if GameState.phase == "setup":
			questions.clear()
			_load())


## Returns null only when every question has been used.
func next_question(score : int) -> TriviaQuestion:
	var preferred := "Easy"
	if score >= 200:
		preferred = "Hard"
	elif score >= 100:
		preferred = "Medium"
	for difficulty in FALLBACK[preferred]:
		var pool := questions.filter(func(q): return not q._used() and q.get_difficulty() == difficulty)
		if not pool.is_empty():
			var q: TriviaQuestion = pool.pick_random()
			q.set_used()
			return q
	return null


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
		if not TriviaQuestion.is_valid_record(question):
			push_warning("QuestionBank: skipped invalid question %s" % str(question.get("id", "?") if question is Dictionary else "?"))
			continue
		questions.append(TriviaQuestion.new(question))
		
	return questions
