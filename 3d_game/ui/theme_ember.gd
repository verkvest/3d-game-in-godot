extends RefCounted

static var _cached: Theme


static func build() -> Theme:
	if _cached != null:
		return _cached
	var theme := Theme.new()
	theme.default_font_size = 24
	var cream := Color("f6ecd4")
	var amber := Color("f0b429")
	theme.set_color("font_color", "Label", cream)
	theme.set_font_size("font_size", "Label", 24)
	theme.set_color("default_color", "RichTextLabel", cream)
	theme.set_font_size("normal_font_size", "RichTextLabel", 22)
	theme.set_color("font_color", "Button", cream)
	theme.set_font_size("font_size", "Button", 30)
	theme.set_color("font_hover_color", "Button", Color("fff6df"))
	theme.set_color("font_pressed_color", "Button", amber)
	theme.set_color("font_focus_color", "Button", cream)
	theme.set_stylebox("normal", "Button", _button(Color("3c2416"), Color("e0a04a")))
	theme.set_stylebox("hover", "Button", _button(Color("5a321c"), Color("ffd27a")))
	theme.set_stylebox("pressed", "Button", _button(Color("2a160e"), Color("ffb24a")))
	theme.set_stylebox("focus", "Button", _button(Color("3c2416"), Color("ffe0a0")))
	theme.set_color("font_color", "Label", cream)
	theme.set_constant("outline_size", "Label", 0)
	_cached = theme
	return theme


static func panel_style() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.12, 0.07, 0.05, 0.94)
	box.border_color = Color("e0a04a")
	box.set_border_width_all(2)
	box.set_corner_radius_all(18)
	box.content_margin_left = 28
	box.content_margin_right = 28
	box.content_margin_top = 22
	box.content_margin_bottom = 22
	return box


static func _button(fill: Color, border: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(2)
	box.set_corner_radius_all(16)
	box.content_margin_left = 26
	box.content_margin_right = 26
	box.content_margin_top = 16
	box.content_margin_bottom = 16
	return box


static func full_rect(control: Control) -> void:
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.offset_left = 0
	control.offset_top = 0
	control.offset_right = 0
	control.offset_bottom = 0


static func add_backdrop(parent: Node) -> void:
	var bg := ColorRect.new()
	bg.color = Color("140c09")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	full_rect(bg)
	parent.add_child(bg)
	var fade := TextureRect.new()
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.35, 1.0])
	gradient.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0.55)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.5, 0.2)
	texture.fill_to = Vector2(0.5, 1.0)
	texture.width = 8
	texture.height = 64
	fade.texture = texture
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fade.stretch_mode = TextureRect.STRETCH_SCALE
	full_rect(fade)
	parent.add_child(fade)
