class_name FxButton
extends Button
## Game-feel button: squishes instantly when tapped (report PP-1: feedback in
## under 200 ms), grows slightly on mouse hover, plays an optional sound.
## Pick a color with `accent` (Purple, Orange, Magenta, Blue, Pink, Green, Red, Gold).

@export_enum("Purple", "Orange", "Magenta", "Blue", "Pink", "Green", "Red", "Gold") var accent: String = "Purple":
	set(value):
		accent = value
		theme_type_variation = value + "Button"
@export var press_sound: AudioStream

var _tw: Tween
var _sfx: AudioStreamPlayer


func _init() -> void:
	theme_type_variation = accent + "Button"
	focus_mode = FOCUS_ALL
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	custom_minimum_size.y = UIStyle.TOUCH_MIN


func _ready() -> void:
	pivot_offset = size / 2
	resized.connect(func(): pivot_offset = size / 2)
	button_down.connect(func(): _animate(0.94, 0.05))
	button_up.connect(func(): _animate(1.0, 0.12))
	mouse_entered.connect(func(): if not disabled: _animate(1.03, 0.12))
	mouse_exited.connect(func(): _animate(1.0, 0.12))
	pressed.connect(_play_sound)


func _animate(target: float, dur: float) -> void:
	if _tw:
		_tw.kill()
	_tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tw.tween_property(self, "scale", Vector2.ONE * target, dur)


## Little side-to-side shake, e.g. when a form has an error.
func shake() -> void:
	if GameSettings.reduce_motion:
		return
	var x := position.x
	var tw := create_tween()
	for d in [-8, 8, -5, 5, 0]:
		tw.tween_property(self, "position:x", x + d, 0.04)


func _play_sound() -> void:
	if press_sound == null:
		return
	if _sfx == null:
		_sfx = AudioStreamPlayer.new()
		_sfx.bus = "SFX"
		add_child(_sfx)
	_sfx.stream = press_sound
	_sfx.play()
