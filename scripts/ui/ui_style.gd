class_name UIStyle
extends RefCounted
## One place for every color, size and font in the game, plus the shared Theme.
## Change a value here and every screen updates.
##
## Sizes follow the project report:
##   SP01  layout fits a 360 x 640 portrait screen with no sideways scrolling
##   SP02  question/instruction text >= 16 px, touch targets >= 44 x 44 px

# --- Palette (taken from the Cosmic Quest mockup) ---------------------------
const BG := Color("#0b0820")
const PANEL := Color("#140f2e")
const PANEL_HI := Color("#221a4a")
const NEBULA_A := Color("#2a1a5e")
const NEBULA_B := Color("#3b2580")
const TEXT := Color("#f4eefc")
const TEXT_DIM := Color("#b9aee0")
const ORANGE := Color("#f5a742")   # main action
const CYAN := Color("#5fd4ff")     # information / trivia
const PURPLE := Color("#9b6bff")   # navigation / secondary
const PINK := Color("#ff7ac8")
const GREEN := Color("#6fe08a")    # correct / success
const RED := Color("#ff5d6c")      # wrong / failure / lives
const GOLD := Color("#ffd36b")     # winner

## Accent name -> color. Each one becomes a theme variation:
## "<Name>Button" and "<Name>Panel" (e.g. "CyanButton", "GoldPanel").
const ACCENTS := {
	"Orange": ORANGE, "Cyan": CYAN, "Purple": PURPLE, "Pink": PINK,
	"Green": GREEN, "Red": RED, "Gold": GOLD,
}

## Each player keeps one color for the whole game so it's obvious whose turn it is.
const PLAYER_ACCENTS: Array[String] = ["Orange", "Cyan", "Pink", "Green"]

# --- Sizes ------------------------------------------------------------------
const FONT_SMALL := 16   # smallest text allowed (SP02)
const FONT_BODY := 16    # DotGothic16 is drawn on a 16 px grid: crisp + reads large
const FONT_H2 := 20
const FONT_H1 := 30
const FONT_LOGO := 48
const TOUCH_MIN := 52    # button height; report minimum is 44
const MARGIN := 16
const GAP := 12
const MAX_CONTENT_WIDTH := 420   # keeps a phone-width column on tablets/desktop

## Body text, numbers and buttons: very clear digits (5 vs S, 0 vs O).
const FONT_PATH := "res://assets/fonts/DotGothic16.ttf"
## Logo and big headings: the chunky style from the mockup.
const DISPLAY_FONT_PATH := "res://assets/fonts/PixelifySans.ttf"

static var _font: Font
static var _bold: Font
static var _display: Font


static func font() -> Font:
	if _font == null:
		_font = load(FONT_PATH)
	return _font


## Slightly thicker body font for emphasis.
static func bold_font() -> Font:
	if _bold == null:
		var fv := FontVariation.new()
		fv.base_font = font()
		fv.variation_embolden = 0.5
		_bold = fv
	return _bold


static func display_font() -> Font:
	if _display == null:
		var fv := FontVariation.new()
		fv.base_font = load(DISPLAY_FONT_PATH)
		var ts := TextServerManager.get_primary_interface()
		fv.variation_opentype = {ts.name_to_tag("wght"): 700}
		_display = fv
	return _display


static func player_accent(player_id: int) -> String:
	return PLAYER_ACCENTS[posmod(player_id, PLAYER_ACCENTS.size())]


static func player_color(player_id: int) -> Color:
	return ACCENTS[player_accent(player_id)]


# --- Small factories used by every screen ------------------------------------

static func label(text: String, size := FONT_BODY, color := TEXT, bold := false,
		align := HORIZONTAL_ALIGNMENT_LEFT, wrap := true) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if bold:
		l.add_theme_font_override("font", bold_font())
	l.horizontal_alignment = align
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## Big outlined heading, like the logo text.
static func heading(text: String, size := FONT_H1, color := TEXT) -> Label:
	var l := label(text, size, color, false, HORIZONTAL_ALIGNMENT_CENTER)
	l.add_theme_font_override("font", display_font())
	l.add_theme_constant_override("outline_size", maxi(6, size / 4))
	l.add_theme_color_override("font_outline_color", NEBULA_B)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	l.add_theme_constant_override("shadow_offset_x", 0)
	l.add_theme_constant_override("shadow_offset_y", 3)
	return l


static func panel(accent := "Purple") -> PanelContainer:
	var p := PanelContainer.new()
	p.theme_type_variation = accent + "Panel"
	return p


static func button(text: String, accent := "Purple", height := TOUCH_MIN) -> FxButton:
	var b := FxButton.new()
	b.text = text
	b.accent = accent
	b.custom_minimum_size.y = height
	return b


static func vbox(separation := GAP) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", separation)
	return v


static func hbox(separation := GAP) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", separation)
	return h


static func spacer(min_height := 0.0, expand := true) -> Control:
	var c := Control.new()
	c.custom_minimum_size.y = min_height
	if expand:
		c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


## Small square in the player's color, shown next to their name.
static func player_chip(player_id: int, size := 14) -> ColorRect:
	var c := ColorRect.new()
	c.color = player_color(player_id)
	c.custom_minimum_size = Vector2(size, size)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


static func box(bg: Color, border: Color, border_w := 3, radius := 6,
		pad := Vector4(14, 10, 14, 10), glow := true) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w)
	s.set_corner_radius_all(radius)
	s.corner_detail = 3          # chunky, pixel-ish corners
	s.anti_aliasing = false
	s.content_margin_left = pad.x
	s.content_margin_top = pad.y
	s.content_margin_right = pad.z
	s.content_margin_bottom = pad.w
	if glow:
		s.shadow_color = Color(border, 0.28)
		s.shadow_size = 6
	return s


# --- Theme --------------------------------------------------------------------

static func make_theme() -> Theme:
	var t := Theme.new()
	t.default_font = font()
	t.default_font_size = FONT_BODY
	t.set_color("font_color", "Label", TEXT)

	# Buttons: default look is purple; accents are type variations.
	_button_styles(t, "Button", PURPLE)
	for accent_name: String in ACCENTS:
		var type_name := accent_name + "Button"
		t.set_type_variation(type_name, "Button")
		_button_styles(t, type_name, ACCENTS[accent_name])

	# Panels
	t.set_stylebox("panel", "PanelContainer", _panel_box(PURPLE))
	t.set_stylebox("panel", "Panel", _panel_box(PURPLE))
	for accent_name: String in ACCENTS:
		var type_name := accent_name + "Panel"
		t.set_type_variation(type_name, "PanelContainer")
		t.set_stylebox("panel", type_name, _panel_box(ACCENTS[accent_name]))

	# Text fields (player names)
	var pad := Vector4(12, 10, 12, 10)
	t.set_stylebox("normal", "LineEdit", box(BG, CYAN, 2, 4, pad, false))
	t.set_stylebox("focus", "LineEdit", box(BG, ORANGE, 2, 4, pad, true))
	t.set_stylebox("read_only", "LineEdit", box(BG, TEXT_DIM, 2, 4, pad, false))
	t.set_color("font_color", "LineEdit", TEXT)
	t.set_color("font_placeholder_color", "LineEdit", Color(TEXT_DIM, 0.6))
	t.set_color("caret_color", "LineEdit", ORANGE)
	t.set_color("selection_color", "LineEdit", Color(CYAN, 0.35))
	t.set_font_size("font_size", "LineEdit", FONT_BODY)
	t.set_constant("minimum_character_width", "LineEdit", 4)

	# Sliders (settings)
	var track := box(NEBULA_A, PURPLE, 1, 0, Vector4(0, 5, 0, 5), false)
	var filled := box(PURPLE, PURPLE, 1, 0, Vector4(0, 5, 0, 5), false)
	t.set_stylebox("slider", "HSlider", track)
	t.set_stylebox("grabber_area", "HSlider", filled)
	t.set_stylebox("grabber_area_highlight", "HSlider", filled)
	t.set_icon("grabber", "HSlider", _rect_tex(16, 26, ORANGE))
	t.set_icon("grabber_highlight", "HSlider", _rect_tex(16, 26, GOLD))
	t.set_icon("grabber_disabled", "HSlider", _rect_tex(16, 26, TEXT_DIM))

	# Toggles (settings)
	var empty := StyleBoxEmpty.new()
	for s in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		t.set_stylebox(s, "CheckButton", empty)
	t.set_icon("checked", "CheckButton", _toggle_tex(true))
	t.set_icon("unchecked", "CheckButton", _toggle_tex(false))
	t.set_icon("checked_mirrored", "CheckButton", _toggle_tex(true))
	t.set_icon("unchecked_mirrored", "CheckButton", _toggle_tex(false))
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		t.set_color(c, "CheckButton", TEXT)

	# Progress bars (for HUD meters your team may add)
	t.set_stylebox("background", "ProgressBar", box(PANEL, CYAN, 2, 2, Vector4.ZERO, false))
	t.set_stylebox("fill", "ProgressBar", box(CYAN, CYAN, 0, 2, Vector4.ZERO, false))
	t.set_color("font_color", "ProgressBar", TEXT)

	# Scrolling (long explanations on small phones)
	t.set_stylebox("panel", "ScrollContainer", StyleBoxEmpty.new())
	t.set_stylebox("scroll", "VScrollBar", box(Color(PANEL, 0.6), Color(0, 0, 0, 0), 0, 2, Vector4(3, 0, 3, 0), false))
	t.set_stylebox("grabber", "VScrollBar", box(PURPLE, PURPLE, 0, 2, Vector4(3, 0, 3, 0), false))
	t.set_stylebox("grabber_highlight", "VScrollBar", box(CYAN, CYAN, 0, 2, Vector4(3, 0, 3, 0), false))
	t.set_stylebox("grabber_pressed", "VScrollBar", box(CYAN, CYAN, 0, 2, Vector4(3, 0, 3, 0), false))
	return t


static func _button_styles(t: Theme, type_name: String, accent: Color) -> void:
	var pad := Vector4(16, 10, 16, 10)
	var pressed := box(PANEL.lerp(accent, 0.38), accent.lightened(0.2), 3, 6, pad)
	t.set_stylebox("normal", type_name, box(PANEL, accent, 3, 6, pad))
	t.set_stylebox("hover", type_name, box(PANEL_HI, accent.lightened(0.15), 3, 6, pad))
	t.set_stylebox("pressed", type_name, pressed)
	t.set_stylebox("hover_pressed", type_name, pressed)
	t.set_stylebox("disabled", type_name, box(PANEL.darkened(0.25), accent.darkened(0.55), 3, 6, pad, false))
	t.set_stylebox("focus", type_name, StyleBoxEmpty.new())
	t.set_color("font_color", type_name, TEXT)
	t.set_color("font_hover_color", type_name, Color.WHITE)
	t.set_color("font_pressed_color", type_name, Color.WHITE)
	t.set_color("font_hover_pressed_color", type_name, Color.WHITE)
	t.set_color("font_focus_color", type_name, TEXT)
	t.set_color("font_disabled_color", type_name, Color(TEXT_DIM, 0.55))
	t.set_font_size("font_size", type_name, FONT_BODY)


static func _panel_box(accent: Color) -> StyleBoxFlat:
	return box(Color(PANEL, 0.94), accent, 2, 8, Vector4(16, 14, 16, 14), true)


static func _rect_tex(w: int, h: int, c: Color) -> ImageTexture:
	var img := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	img.fill(c)
	img.fill_rect(Rect2i(0, h - 4, w, 4), c.darkened(0.35))
	img.fill_rect(Rect2i(0, 0, w, 2), c.lightened(0.3))
	return ImageTexture.create_from_image(img)


static func _toggle_tex(on: bool) -> ImageTexture:
	var w := 56
	var h := 30
	var img := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	var border := CYAN if on else Color("#6b5f94")
	img.fill(border)
	img.fill_rect(Rect2i(3, 3, w - 6, h - 6), PANEL.lerp(CYAN, 0.3) if on else PANEL)
	var knob_x := w - 25 if on else 5
	img.fill_rect(Rect2i(knob_x, 6, 20, h - 12), border.lightened(0.2) if on else border)
	return ImageTexture.create_from_image(img)
