extends GutTest
## TS-007: Main Menu and About Page
## Sponsor request: an About page with the team's names. Team decision
## (Nov 12, 2026): the page shows the team plus a section on the project and
## the Psyche mission (educational goal, problem statement 3.2).

const MENU_SCENE := "res://scenes/main_menu.tscn"
const ABOUT_SCENE := "res://scenes/about.tscn"


func _all_text(node: Node) -> String:
	var out := ""
	for c in node.find_children("*", "", true, false):
		if c is Label or c is Button or c is RichTextLabel:
			out += c.text + "\n"
	return out


func _about() -> Node:
	if not ResourceLoader.exists(ABOUT_SCENE):
		return null
	var a = load(ABOUT_SCENE).instantiate()
	add_child_autofree(a)
	return a


## TC-026 (Integration): the main menu has an About button that leads to the About page.
func test_tc026_menu_has_about_button() -> void:
	var menu = load(MENU_SCENE).instantiate()
	add_child_autofree(menu)
	await wait_physics_frames(2)
	var found := false
	for b in menu.find_children("*", "Button", true, false):
		if "About" in b.text:
			found = true
			assert_true(b.has_meta("target_scene"), "About button knows where it goes")
			if b.has_meta("target_scene"):
				assert_eq(b.get_meta("target_scene"), ABOUT_SCENE)
	assert_true(found, "Menu has an About button")


## TC-027 (Integration): the About page lists every team member and has no
## advisors, resources or credits sections (team decision, Nov 12 2026).
func test_tc027_about_lists_team_only() -> void:
	var a = _about()
	assert_not_null(a, "About scene exists")
	if a == null:
		return
	await wait_physics_frames(2)
	var text := _all_text(a)
	for name in ["Ella Mariani", "Sanjith Varathan", "Savannah Wilhelm", "Gerardo Saca"]:
		assert_string_contains(text, name)
	for removed in ["Advisors", "Resources", "Credits"]:
		assert_false(removed in text, "No '%s' section" % removed)


## TC-028 (Integration): the About page explains the project and the Psyche mission.
func test_tc028_about_explains_project_and_mission() -> void:
	var a = _about()
	assert_not_null(a, "About scene exists")
	if a == null:
		return
	await wait_physics_frames(2)
	var text := _all_text(a)
	assert_string_contains(text, "About this game")
	assert_string_contains(text, "pass-and-play")
	assert_string_contains(text, "The Psyche mission")
	assert_string_contains(text, "metal-rich asteroid")
	assert_string_contains(text, "2029")
