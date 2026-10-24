extends Control

const THEME := preload("res://ui/theme_ember.gd")
const MARGINS := preload("res://scripts/safe_margins.gd")

var _margin: MarginContainer


func _ready() -> void:
	theme = THEME.build()
	THEME.full_rect(self)
	THEME.add_backdrop(self)
	Game.back_pressed.connect(_on_back)
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
	column.custom_minimum_size = Vector2(560, 0)
	column.add_theme_constant_override("separation", 16)
	center.add_child(column)

	var icon := TextureRect.new()
	icon.texture = load("res://icon.png")
	icon.custom_minimum_size = Vector2(168, 168)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	column.add_child(icon)

	var title := Label.new()
	title.text = "Pyrewick"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color("f0b429"))
	column.add_child(title)

	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 4)
	rule.color = Color("e07a32")
	column.add_child(rule)

	var subtitle := Label.new()
	subtitle.text = "Five torchlit holds. One brass key."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 26)
	subtitle.add_theme_color_override("font_color", Color("f6ecd4"))
	column.add_child(subtitle)

	var blurb := Label.new()
	blurb.text = "Walk the ruined vaults, pocket every cinder, and carry the key into the ember ring."
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	blurb.add_theme_font_size_override("font_size", 20)
	blurb.add_theme_color_override("font_color", Color("c4b39a"))
	column.add_child(blurb)

	var play := Button.new()
	play.text = "Enter the vault"
	play.custom_minimum_size = Vector2(0, 76)
	play.pressed.connect(func() -> void: Game.start_new_run())
	column.add_child(play)

	var credits := Button.new()
	credits.text = "Credits & licenses"
	credits.custom_minimum_size = Vector2(0, 68)
	credits.pressed.connect(func() -> void: Game.open_credits("res://ui/main_menu.tscn"))
	column.add_child(credits)

	var controls := Label.new()
	controls.text = "Landscape. Left stick to move, drag the right side to look, JUMP to hop. Keyboard: WASD, mouse, space."
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 18)
	controls.add_theme_color_override("font_color", Color("c4b39a"))
	column.add_child(controls)


func _on_back() -> void:
	get_tree().quit()
