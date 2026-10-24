extends Control

const THEME := preload("res://ui/theme_ember.gd")
const MARGINS := preload("res://scripts/safe_margins.gd")

var _margin: MarginContainer


func _ready() -> void:
	theme = THEME.build()
	THEME.full_rect(self)
	THEME.add_backdrop(self)
	Game.back_pressed.connect(_back)
	_build()


func _process(_delta: float) -> void:
	if _margin == null:
		return
	var margins := MARGINS.get_margins(self)
	_margin.add_theme_constant_override("margin_left", int(margins.x + 16))
	_margin.add_theme_constant_override("margin_top", int(margins.y + 8))
	_margin.add_theme_constant_override("margin_right", int(margins.z + 16))
	_margin.add_theme_constant_override("margin_bottom", int(margins.w + 8))


func _build() -> void:
	_margin = MarginContainer.new()
	THEME.full_rect(_margin)
	add_child(_margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_margin.add_child(column)

	var title := Label.new()
	title.text = "Credits & licenses"
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color("f0b429"))
	column.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)

	var body := RichTextLabel.new()
	body.bbcode_enabled = false
	body.scroll_active = false
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.fit_content = true
	body.text = _notice_text()
	scroll.add_child(body)

	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(0, 68)
	back.pressed.connect(_back)
	column.add_child(back)


func _notice_text() -> String:
	var path := "res://THIRD_PARTY_LICENSES.txt"
	if FileAccess.file_exists(path):
		return FileAccess.get_file_as_string(path)
	return "License text is missing from the build."


func _back() -> void:
	get_tree().change_scene_to_file(Game.return_scene)
