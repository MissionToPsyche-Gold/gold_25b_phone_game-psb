class_name TriviaController
extends RefCounted


signal trivia_started(player : int) #int but needs to be changed to Player
signal trivia_completed(correct : bool)

@export var timer: float = 15.0

var trivia_model : TriviaModel
var trivia_view : Control

func _startTurn()->void:
	trivia_view.get_tree().change_scene_to_file(
		"res://scnenes/trivia.tscn"
	)
	
	pass
	
func _submitAnswer(correct: bool) -> void:
	
	# GameController.onTriviaCompleted()
	pass

func _selectQuestion() -> TriviaQuestion:
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
