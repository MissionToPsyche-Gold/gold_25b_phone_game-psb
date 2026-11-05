class_name TriviaScreen
extends UIScreen
## One trivia turn: HUD, the question, four answers, then feedback with the
## correct answer and explanation (report UF-4, UF-6, UF-7, SF07-SF14).
##
## Only the FIRST tap counts; later taps are ignored (SF08). The screen does
## not decide right/wrong: it emits `answer_selected` and waits for the game
## logic to call show_feedback().

signal answer_selected(index: int)
signal continue_pressed
signal pause_pressed

const LETTERS := ["A", "B", "C", "D"]

var hud: PlayerHud
var _scroll: ScrollContainer
var _q_panel: PanelContainer
var _question: Label
var _answers: Array[FxButton] = []
var _feedback: PanelContainer
var _fb_title: Label
var _fb_delta: Label
var _fb_answer: Label
var _fb_explain: Label
var _continue: FxButton
var _locked := false
var _round := 1
var _choices: Array = []


func _ready() -> void:
	var column := ResponsiveColumn.new()
	column.top_margin = 12
	add_child(column)
	var outer := UIStyle.vbox(12)
	column.add_child(outer)

	hud = PlayerHud.new()
	hud.pause_pressed.connect(pause_pressed.emit)
	outer.add_child(hud)

	var content := UIStyle.vbox(12)
	_scroll = UIScreen.scroll_wrap(content)
	outer.add_child(_scroll)

	_q_panel = UIStyle.panel("Cyan")
	content.add_child(_q_panel)
	var qcol := UIStyle.vbox(8)
	_q_panel.add_child(qcol)
	qcol.add_child(UIStyle.label("PSYCHE TRIVIA", UIStyle.FONT_SMALL, UIStyle.CYAN, true))
	_question = UIStyle.label("", UIStyle.FONT_H2, UIStyle.TEXT, true)
	qcol.add_child(_question)

	for i in 4:
		var b := UIStyle.button("", "Purple", 58)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.pressed.connect(_on_answer.bind(i))
		content.add_child(b)
		_answers.append(b)

	_feedback = UIStyle.panel("Green")
	_feedback.visible = false
	content.add_child(_feedback)
	var fcol := UIStyle.vbox(10)
	_feedback.add_child(fcol)
	var fb_top := UIStyle.hbox(8)
	fcol.add_child(fb_top)
	_fb_title = UIStyle.label("", UIStyle.FONT_H2, UIStyle.GREEN, true, HORIZONTAL_ALIGNMENT_LEFT, false)
	_fb_title.size_flags_horizontal = SIZE_EXPAND_FILL
	fb_top.add_child(_fb_title)
	_fb_delta = UIStyle.label("", UIStyle.FONT_BODY, UIStyle.GOLD, true, HORIZONTAL_ALIGNMENT_RIGHT, false)
	fb_top.add_child(_fb_delta)
	_fb_answer = UIStyle.label("", UIStyle.FONT_BODY, UIStyle.TEXT, true)
	fcol.add_child(_fb_answer)
	_fb_explain = UIStyle.label("", UIStyle.FONT_BODY, UIStyle.TEXT_DIM)
	fcol.add_child(_fb_explain)
	_continue = UIStyle.button("Continue  >", "Orange", 56)
	_continue.pressed.connect(_on_continue)
	fcol.add_child(_continue)


## player = {"id","name","score","lives"}; choices = exactly 4 strings.
func show_question(player: Dictionary, round_number: int, question: String, choices: Array) -> void:
	_round = round_number
	_locked = false
	_choices = choices.duplicate()
	hud.set_player(player, round_number, false)
	_question.text = question
	_feedback.visible = false
	for i in 4:
		var b := _answers[i]
		b.visible = true
		b.accent = "Purple"
		b.disabled = false
		b.mouse_filter = MOUSE_FILTER_STOP
		b.modulate = Color.WHITE
		b.text = "%s    %s" % [LETTERS[i], str(choices[i]) if i < choices.size() else ""]
	_scroll.scroll_vertical = 0


func on_shown() -> void:
	pop_in([_q_panel] + _answers, 0.05, 0.08)


## Call after the game logic has checked the answer.
## player_after = the player's updated {"score","lives",...}.
## score_delta / lives_delta: what this answer changed (e.g. 10 / 0 or 0 / -1).
func show_feedback(correct_index: int, chosen_index: int, explanation: String,
		player_after: Dictionary, score_delta: int, lives_delta: int) -> void:
	_locked = true
	var correct := correct_index == chosen_index
	for i in 4:
		var b := _answers[i]
		b.mouse_filter = MOUSE_FILTER_IGNORE
		b.scale = Vector2.ONE
		if i == correct_index:
			b.accent = "Green"
		elif i == chosen_index:
			b.accent = "Red"
		else:
			b.visible = false   # make room for the explanation
	_feedback.theme_type_variation = "GreenPanel" if correct else "RedPanel"
	_fb_title.text = "Correct!" if correct else "Not quite"
	_fb_title.add_theme_color_override("font_color", UIStyle.GREEN if correct else UIStyle.RED)
	var parts: Array[String] = []
	if score_delta != 0:
		parts.append(("+%d pts" if score_delta > 0 else "%d pts") % score_delta)
	if lives_delta != 0:
		parts.append(("+%d life" if lives_delta > 0 else "%d life") % lives_delta)
	_fb_delta.text = "  ".join(parts)
	_fb_delta.add_theme_color_override("font_color", UIStyle.GOLD if lives_delta >= 0 else UIStyle.RED)
	var answer_text := str(_choices[correct_index]) if correct_index >= 0 and correct_index < _choices.size() else ""
	_fb_answer.text = "Answer: %s" % answer_text
	_fb_explain.text = explanation
	_continue.disabled = false
	_feedback.visible = true
	hud.set_player(player_after, _round, true)
	pop_in([_feedback], 0.0)
	await get_tree().process_frame
	_scroll.ensure_control_visible(_continue)


func _on_answer(i: int) -> void:
	if _locked:
		return
	_locked = true
	for b in _answers:
		b.mouse_filter = MOUSE_FILTER_IGNORE
	_answers[i].accent = "Cyan"   # "selected" look until the result comes back
	answer_selected.emit(i)


func _on_continue() -> void:
	_continue.disabled = true      # one tap only
	continue_pressed.emit()
