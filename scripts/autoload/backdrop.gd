extends CanvasLayer
## Autoload "Backdrop": the animated space scene behind EVERY screen.
## It lives outside the scenes, so when GameFlow switches scenes the stars,
## meteors and Psyche keep moving instead of restarting.
## Scenes just call Backdrop.use_menu_layout() or Backdrop.use_game_layout().

var background: SpaceBackground


func _ready() -> void:
	layer = -10   # always behind the current scene
	background = SpaceBackground.new()
	add_child(background)
	use_menu_layout(false)


## Big Psyche + spacecraft, like the title screen mockup.
func use_menu_layout(animate := true) -> void:
	background.set_layout(Vector2(0.86, 0.95), 3.0, Vector2(0.24, 0.935), 2.0, animate,
		Vector2(0.84, 0.07), 1.0)


## Psyche tucked into the bottom corner and the planet/spacecraft moved to the
## screen edge, so nothing sits behind titles, text or buttons.
func use_game_layout(animate := true) -> void:
	background.set_layout(Vector2(0.97, 1.02), 1.8, Vector2(1.04, 0.62), 1.0, animate,
		Vector2(-0.01, 0.40), 0.55)
