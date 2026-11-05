class_name TriviaQuestion
extends RefCounted

var id : int
var asked : bool = false
var question : String
var answers : Array[String]
var correct_answer : int
var explanation : String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _init(data : Dictionary) -> void:
	id = data["id"]
	question = data["question"]
	answers.assign(data["answers"])
	correct_answer = data["correct answer"]
	explanation = data["explanation"]
	
func is_correct(choice_index : int) -> bool:
	return choice_index == correct_answer

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
