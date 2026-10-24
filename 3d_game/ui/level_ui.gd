extends CanvasLayer

const THEME := preload("res://ui/theme_ember.gd")
const MARGINS := preload("res://scripts/safe_margins.gd")

var _title: Label
var _hint: Label
var _coins: Label
var _key: Label
var _toast: Label
var _toast_time := 0.0
var _clear_panel: PanelContainer
var _clear_button: Button
var _pause_panel: PanelContainer
var _margin: MarginContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	_build()
	Game.coins_changed.connect(_refresh)
	Game.key_changed.connect(_refresh)
	Game.level_cleared.connect(_on_cleared)
	Game.back_pressed.connect(_on_back)
	_refresh()


func bind(_level: Node) -> void:
	pass


func _process(delta: float) -> void:
	if _toast_time > 0.0:
		_toast_time -= delta
		if _toast_time <= 0.0:
			_toast.visible = false
	var margins := MARGINS.get_margins(self)
	if _margin:
		_margin.add_theme_constant_override("margin_left", int(margins.x))
		_margin.add_theme_constant_override("margin_top", int(margins.y))
		_margin.add_theme_constant_override("margin_right", int(margins.z))
		_margin.add_theme_constant_override("margin_bottom", int(margins.w))


func flash(text: String) -> void:
	_toast.text = text
	_toast.visible = true
	_toast_time = 1.8


func _build() -> void:
	var root := Control.new()
	root.theme = THEME.build()
	THEME.full_rect(root)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var scrim := ColorRect.new()
	scrim.color = Color(0.04, 0.02, 0.015, 0.62)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim.set_anchors_preset(Control.PRESET_TOP_WIDE)
	scrim.offset_left = 0
	scrim.offset_right = 0
	scrim.offset_top = 0
	scrim.offset_bottom = 124
	root.add_child(scrim)

	_margin = MarginContainer.new()
	THEME.full_rect(_margin)
	_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_margin)

	var board := Control.new()
	board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_margin.add_child(board)

	_title = _label(board, 34)
	_title.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_title.offset_right = 780
	_title.offset_bottom = 48

	_hint = _label(board, 20)
	_hint.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_hint.offset_top = 46
	_hint.offset_right = 760
	_hint.offset_bottom = 110
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.modulate = Color("c4b39a")

	_coins = _label(board, 28)
	_coins.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_coins.offset_left = -180
	_coins.offset_right = 180
	_coins.offset_bottom = 44
	_coins.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_key = _label(board, 26)
	_key.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_key.offset_left = -420
	_key.offset_top = 52
	_key.offset_right = -16
	_key.offset_bottom = 96
	_key.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	var pause := Button.new()
	pause.text = "Pause"
	pause.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause.offset_left = -168
	pause.offset_top = 0
	pause.offset_right = 0
	pause.offset_bottom = 64
	pause.pressed.connect(_toggle_pause)
	board.add_child(pause)

	_toast = _label(board, 26)
	_toast.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_toast.offset_left = -360
	_toast.offset_right = 360
	_toast.offset_top = -210
	_toast.offset_bottom = -160
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.visible = false

	_pause_panel = _panel(board)
	var resume := Button.new()
	resume.text = "Resume"
	resume.pressed.connect(_toggle_pause.bind(false))
	_pause_panel.get_node("Box").add_child(resume)
	var restart := Button.new()
	restart.text = "Restart hold"
	restart.pressed.connect(func() -> void: Game.restart_level())
	_pause_panel.get_node("Box").add_child(restart)
	var menu := Button.new()
	menu.text = "Main menu"
	menu.pressed.connect(func() -> void: Game.quit_to_menu())
	_pause_panel.get_node("Box").add_child(menu)
	_pause_panel.visible = false

	_clear_panel = _panel(board)
	_clear_button = Button.new()
	_clear_button.pressed.connect(func() -> void: Game.continue_after_clear())
	_clear_panel.get_node("Box").add_child(_clear_button)
	_clear_panel.visible = false


func _label(parent: Node, font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _panel(parent: Node) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -280
	panel.offset_right = 280
	panel.offset_top = -200
	panel.offset_bottom = 200
	panel.add_theme_stylebox_override("panel", THEME.panel_style())
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	var box := VBoxContainer.new()
	box.name = "Box"
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	parent.add_child(panel)
	return panel


func _refresh() -> void:
	var spec: Dictionary = Game.current()
	_title.text = "%s   ·   %d / %d" % [spec["title"], Game.level_index + 1, Game.level_count()]
	_hint.text = spec["hint"]
	_coins.text = "Cinders  %d / %d" % [Game.level_coins, Game.level_goal]
	_key.text = "Brass key in hand" if Game.has_key else "Find the brass key"
	_key.modulate = Color("f0b429") if Game.has_key else Color("c4b39a")


func _on_cleared() -> void:
	get_tree().paused = true
	Touch.clear()
	_pause_panel.visible = false
	var heading := Label.new()
	heading.text = "The ring is lit"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 36)
	var detail := Label.new()
	detail.text = "Cinders this hold: %d / %d" % [Game.level_coins, Game.level_goal]
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var box: VBoxContainer = _clear_panel.get_node("Box")
	box.add_child(heading)
	box.move_child(heading, 0)
	box.add_child(detail)
	box.move_child(detail, 1)
	_clear_button.text = "Leave the vault" if Game.is_last_level() else "Next hold"
	_clear_panel.visible = true


func _toggle_pause(force: Variant = null) -> void:
	if _clear_panel.visible:
		return
	var paused := not get_tree().paused
	if force is bool:
		paused = force
	get_tree().paused = paused
	_pause_panel.visible = paused
	if paused:
		Touch.clear()


func _on_back() -> void:
	if _clear_panel.visible:
		return
	_toggle_pause(false if get_tree().paused else true)
