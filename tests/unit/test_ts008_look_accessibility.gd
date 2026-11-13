extends GutTest
## TS-008: Look and Accessibility
## Requirements: SP01, SP02, SP03; sponsor brand guide (Psyche palette)


## TC-029 (Unit): text is at least 16 px and buttons at least 44 px tall.
func test_tc029_minimum_text_and_touch_sizes() -> void:
	assert_gte(UIStyle.FONT_SMALL, 16, "Smallest text >= 16 px (SP02)")
	assert_gte(UIStyle.FONT_BODY, 16, "Body text >= 16 px (SP02)")
	assert_gte(UIStyle.TOUCH_MIN, 44, "Buttons >= 44 px (SP02)")
	var b := UIStyle.button("Test")
	autofree(b)
	assert_gte(b.custom_minimum_size.y, 44.0, "Factory buttons meet the minimum")


## TC-030 (Unit): the accent palette uses Psyche brand magenta and contains no
## turquoise/cyan color (sponsor request).
func test_tc030_brand_magenta_no_turquoise() -> void:
	assert_true(UIStyle.ACCENTS.has("Magenta"), "Palette has a Magenta accent")
	var colors: Array = UIStyle.ACCENTS.values()
	for id in 4:
		colors.append(UIStyle.player_color(id))
	for c: Color in colors:
		var hue := c.h * 360.0
		var turquoise := hue >= 160.0 and hue <= 200.0 and c.s > 0.3
		assert_false(turquoise, "Color %s is turquoise/cyan" % c.to_html(false))
