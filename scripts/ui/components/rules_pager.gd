class_name RulesPager
extends VBoxContainer
## Step-by-step "How to play" cards with a looping picture on each.
## Used by the How to Play screen (from the menu) and the in-game rules
## screen before the first turn (report UC-2, steps 2-3).
##
## Rule text lives in PAGES below. Keep it in sync with the game logic.

signal finished      # tapped the button on the last page
signal exited        # tapped Back on the first page

const PAGES := [
	{"icon": "pass", "title": "Pass the phone",
		"body": "2 to 4 players share one phone. When your name shows up, it's your turn. Everyone else, no peeking!"},
	{"icon": "trivia", "title": "Answer Psyche trivia",
		"body": "Tap one of the four answers. A correct answer earns 10 points. Then you'll see the right answer and why."},
	{"icon": "lives", "title": "Watch your lives",
		"body": "Everyone starts with 3 lives. A wrong answer costs 1 life. At 0 lives you're out of the game."},
	{"icon": "minigame", "title": "Bonus challenges",
		"body": "After everyone has answered, each player still in the game tries a quick bonus challenge, like the Maze. Win it to get back a lost life (up to 3)."},
	{"icon": "win", "title": "Win the mission",
		"body": "The game ends when only one player is left or the questions run out. Players still in the game rank first, then by score."},
]

@export var finish_text := "Done"

var _page := 0
var _icon: RuleIcon
var _title: Label
var _body: Label
var _count: Label
var _back: FxButton
var _next: FxButton
var _card: PanelContainer


func _ready() -> void:
	add_theme_constant_override("separation", UIStyle.GAP)
	_card = UIStyle.panel("Magenta")
	_card.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(_card)
	var col := UIStyle.vbox(14)
	_card.add_child(col)
	_count = UIStyle.label("", UIStyle.FONT_SMALL, UIStyle.MAGENTA, false, HORIZONTAL_ALIGNMENT_RIGHT)
	col.add_child(_count)
	_icon = RuleIcon.new()
	_icon.custom_minimum_size.y = 84
	col.add_child(_icon)
	_title = UIStyle.label("", UIStyle.FONT_H2, UIStyle.MAGENTA, true, HORIZONTAL_ALIGNMENT_CENTER)
	col.add_child(_title)
	_body = UIStyle.label("", UIStyle.FONT_BODY, UIStyle.TEXT, false, HORIZONTAL_ALIGNMENT_CENTER)
	col.add_child(_body)

	var nav := UIStyle.hbox()
	add_child(nav)
	_back = UIStyle.button("< Back", "Purple")
	_back.size_flags_horizontal = SIZE_EXPAND_FILL
	_back.pressed.connect(_on_back)
	nav.add_child(_back)
	_next = UIStyle.button("Next >", "Magenta")
	_next.size_flags_horizontal = SIZE_EXPAND_FILL
	_next.pressed.connect(_on_next)
	nav.add_child(_next)
	show_page(0, false)


func reset() -> void:
	show_page(0, false)


func show_page(i: int, animate := true) -> void:
	_page = clampi(i, 0, PAGES.size() - 1)
	var p: Dictionary = PAGES[_page]
	_icon.kind = p.icon
	_title.text = p.title
	_body.text = p.body
	_count.text = "%d / %d" % [_page + 1, PAGES.size()]
	var last := _page == PAGES.size() - 1
	_next.text = finish_text if last else "Next >"
	_next.accent = "Orange" if last else "Magenta"
	if animate and not GameSettings.reduce_motion:
		_card.modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(_card, "modulate:a", 1.0, 0.18)


func _on_next() -> void:
	if _page == PAGES.size() - 1:
		finished.emit()
	else:
		show_page(_page + 1)


func _on_back() -> void:
	if _page == 0:
		exited.emit()
	else:
		show_page(_page - 1)
