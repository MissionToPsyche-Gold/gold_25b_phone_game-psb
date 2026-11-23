extends GutTest
## TS-001: Player Setup
## Requirements: UF-1, UF-2, SF01-SF04, UC-1
## Sponsor change (Nov 2026): players pick a ready-made NASA/Psyche callsign
## instead of typing a nickname, so nobody can enter inappropriate names.

const CALLSIGNS_PATH := "res://scripts/ui/callsigns.gd"


func _setup_screen() -> PlayerSetupScreen:
	var s := PlayerSetupScreen.new()
	add_child_autofree(s)
	return s


## TC-001 (Unit): the game accepts 2, 3 or 4 players and rejects 1 or 5.
func test_tc001_player_count_limits() -> void:
	for n in [2, 3, 4]:
		var names := []
		for i in n:
			names.append("Player %d" % i)
		assert_eq(GameState.start_session(names, 0), "", "%d players should be accepted" % n)
	assert_ne(GameState.start_session(["Solo"], 0), "", "1 player should be rejected")
	assert_ne(GameState.start_session(["A", "B", "C", "D", "E"], 0), "", "5 players should be rejected")
	GameState.clear_session()


## TC-002 (Unit): there is a list of at least 8 ready-made callsigns, each unique,
## 1-20 characters, using only letters, spaces and hyphens.
func test_tc002_callsign_list_is_valid() -> void:
	var script = load(CALLSIGNS_PATH) if ResourceLoader.exists(CALLSIGNS_PATH) else null
	assert_not_null(script, "Callsigns script should exist")
	if script == null:
		return
	var names: Array = script.NAMES
	assert_gte(names.size(), 8, "At least 8 callsigns so 4 players always have choices")
	var seen := {}
	var allowed := RegEx.create_from_string("^[A-Za-z][A-Za-z \\-]*$")
	for n: String in names:
		assert_false(seen.has(n), "Duplicate callsign: %s" % n)
		seen[n] = true
		assert_between(n.length(), 1, 20, "Length of %s" % n)
		assert_not_null(allowed.search(n), "Only letters/spaces/hyphens: %s" % n)


## TC-003 (Unit): the setup screen has no free-text name fields.
func test_tc003_no_free_text_entry() -> void:
	var s := _setup_screen()
	var line_edits := s.find_children("*", "LineEdit", true, false)
	assert_eq(line_edits.size(), 0, "Setup must not contain any LineEdit")


## TC-004 (Unit): two players cannot pick the same callsign.
func test_tc004_duplicate_callsign_rejected() -> void:
	var s := _setup_screen()
	assert_true(s.has_method("set_callsign"), "Setup screen should have set_callsign()")
	if not s.has_method("set_callsign"):
		return
	var first: String = s.get_selected_names()[0]
	var accepted: bool = s.set_callsign(1, first)
	assert_false(accepted, "Player 2 must not be able to take Player 1's callsign")
	assert_ne(s.get_selected_names()[1], first, "Player 2 keeps a different callsign")


## TC-005 (Unit): confirming emits one distinct callsign per player.
func test_tc005_confirm_emits_selected_callsigns() -> void:
	var s := _setup_screen()
	assert_true(s.has_method("get_selected_names"), "Setup screen should have get_selected_names()")
	if not s.has_method("get_selected_names"):
		return
	s._set_count(3)
	watch_signals(s)
	s._on_start()
	assert_signal_emitted(s, "confirmed")
	var names: PackedStringArray = get_signal_parameters(s, "confirmed")[0]
	assert_eq(names.size(), 3, "Three players -> three names")
	var unique := {}
	for n in names:
		unique[n] = true
	assert_eq(unique.size(), 3, "Names are distinct")
