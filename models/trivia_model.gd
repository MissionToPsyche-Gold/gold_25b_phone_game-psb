class_name TriviaModel
extends RefCounted

var question : TriviaQuestion
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func select_question()->TriviaQuestion:
	return question
	
func check_answer(choice_index: int) -> bool:
	return false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
