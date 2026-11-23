extends GutTest
## TS-008: Look and Accessibility (integration part)
## Requirements: SP01 (portrait 360 x 640, no sideways scrolling)

const SCENES := [
	"res://scenes/main_menu.tscn",
	"res://scenes/how_to_play.tscn",
	"res://scenes/settings.tscn",
	"res://scenes/player_setup.tscn",
	"res://scenes/about.tscn",
]


## TC-031 (Integration): menu and setup screens fit inside a 360 px wide phone.
func test_tc031_screens_fit_phone_width() -> void:
	var width := 360.0
	for path in SCENES:
		assert_true(ResourceLoader.exists(path), "%s exists" % path)
		if not ResourceLoader.exists(path):
			continue
		var holder := Control.new()
		holder.size = Vector2(width, 640)
		add_child_autofree(holder)
		var scene: Control = load(path).instantiate()
		holder.add_child(scene)
		scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		await wait_seconds(1.2)   # let intro animations finish
		var worst := 0.0
		for c in scene.find_children("*", "Control", true, false):
			if c.is_visible_in_tree() and not c.top_level and c.size.x > 0:
				worst = maxf(worst, c.get_global_rect().end.x - holder.global_position.x)
		assert_lte(worst, width + 1.0, "%s fits in %d px (widest edge %.0f)" % [path, width, worst])
		holder.queue_free()
