extends Control

const THEME := preload("res://ui/theme_ember.gd")
const MARGINS := preload("res://scripts/safe_margins.gd")

var _margin: MarginContainer


func _ready() -> void:
	theme = THEME.build()
	THEME.full_rect(self)
	THEME.add_backdrop(self)
	Game.back_pressed.connect(func() -> void: Game.quit_to_menu())
	_build()


func _process(_delta: float) -> void:
	if _margin == null:
		return
	var margins := MARGINS.get_margins(self)
	_margin.add_theme_constant_override("margin_left", int(margins.x + 12))
	_margin.add_theme_constant_override("margin_top", int(margins.y + 8))
	_margin.add_theme_constant_override("margin_right", int(margins.z + 12))
	_margin.add_theme_constant_override("margin_bottom", int(margins.w + 8))


func _build() -> void:
	_margin = MarginContainer.new()
	THEME.full_rect(_margin)
	add_child(_margin)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_margin.add_child(center)
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(620, 0)
	column.add_theme_constant_override("separation", 16)
	center.add_child(column)

	var kicker := Label.new()
	kicker.text = "PYREWICK"
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kicker.add_theme_font_size_override("font_size", 22)
	kicker.add_theme_color_override("font_color", Color("e07a32"))
	column.add_child(kicker)

	var title := Label.new()
	title.text = "The rings stay lit"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 60)
	title.add_theme_color_override("font_color", Color("f0b429"))
	column.add_child(title)

	var body := Label.new()
	body.text = "Five holds opened. You carried %d cinders out of the dark, brass key still warm." % Game.total_coins
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", 24)
	column.add_child(body)

	var again := Button.new()
	again.text = "Walk them again"
	again.custom_minimum_size = Vector2(0, 76)
	again.pressed.connect(func() -> void: Game.start_new_run())
	column.add_child(again)

	var credits := Button.new()
	credits.text = "Credits & licenses"
	credits.custom_minimum_size = Vector2(0, 68)
	credits.pressed.connect(func() -> void: Game.open_credits("res://ui/end_screen.tscn"))
	column.add_child(credits)

	var menu := Button.new()
	menu.text = "Main menu"
	menu.custom_minimum_size = Vector2(0, 68)
	menu.pressed.connect(func() -> void: Game.quit_to_menu())
	column.add_child(menu)
