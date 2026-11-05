extends Node
## Autoload "QuestionBank" - PLACEHOLDER so the themed trivia scene works now.
## The trivia teammate can replace this with their own question handling.
##   - loads data/sample_questions.json
##   - keeps only valid questions: id, text, 4 choices, correct_index 0-3 (SD03)
##   - never repeats a question within a session (UF-5, SF09, SF10)
##   - forgets used questions when GameState starts a new session

const QUESTIONS_PATH := "res://data/sample_questions.json"

var questions: Array = []
var _used := {}


func _ready() -> void:
	questions = _load()
	GameState.state_changed.connect(func():
		if GameState.phase == "setup":
			_used.clear())


## Returns {} when every question has been used.
func next_question() -> Dictionary:
	var pool := questions.filter(func(q): return not _used.has(q.id))
	if pool.is_empty():
		return {}
	var q: Dictionary = pool.pick_random()
	_used[q.id] = true
	return q


func _load() -> Array:
	var f := FileAccess.open(QUESTIONS_PATH, FileAccess.READ)
	if f == null:
		push_error("QuestionBank: can't open " + QUESTIONS_PATH)
		return []
	var data = JSON.parse_string(f.get_as_text())
	var out: Array = []
	if not data is Dictionary:
		push_error("QuestionBank: invalid JSON in " + QUESTIONS_PATH)
		return out
	for q in data.get("questions", []):
		if q is Dictionary and q.has("id") and str(q.get("question", "")).strip_edges() != "" \
				and q.get("choices", []) is Array and q.choices.size() == 4 \
				and int(q.get("correct_index", -1)) in [0, 1, 2, 3]:
			out.append(q)
		else:
			push_warning("QuestionBank: skipped invalid question %s" % str(q.get("id", "?")))
	return out
