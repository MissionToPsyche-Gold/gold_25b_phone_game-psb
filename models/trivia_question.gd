class_name TriviaQuestion
extends RefCounted

var id : int
var asked : bool = false
var question : String
var answers : Array[String]
var correct_answer : int
var explanation : String
var difficulty : String
var image_path : String = ""   # optional picture shown with the question


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _init(data : Dictionary) -> void:
	id = data["id"]
	question = data["question"]
	answers.assign(data["answers"])
	correct_answer = data["correct answer"]
	explanation = data["explanation"]
	difficulty = data["difficulty"]
	image_path = str(data.get("image", ""))


## True if `data` can be turned into a question (report SD03): text, exactly
## 4 answers, a correct index 0-3, an explanation and a known difficulty.
## The question bank skips records that fail this instead of crashing.
static func is_valid_record(data) -> bool:
	if not data is Dictionary:
		return false
	for key in ["id", "question", "answers", "correct answer", "explanation", "difficulty"]:
		if not data.has(key):
			return false
	if str(data["question"]).strip_edges().is_empty():
		return false
	if not data["answers"] is Array or data["answers"].size() != 4:
		return false
	var index = data["correct answer"]
	if not (index is int or index is float) or int(index) < 0 or int(index) > 3:
		return false
	return data["difficulty"] in ["Easy", "Medium", "Hard"]


func has_image() -> bool:
	return not image_path.is_empty()


func get_image_path() -> String:
	return image_path
	
func is_correct(choice_index : int) -> bool:
	return choice_index == correct_answer

func get_difficulty() -> String:
	return difficulty
	
func get_question() -> String:
	return question
	
func get_answers() -> Array:
	return answers
	
func get_correct_index() -> int:
	return correct_answer
	
func get_explanation() -> String:
	return explanation

func _used() ->bool:
	return asked
	
func set_used() -> void:
	asked = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
