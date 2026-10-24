extends Control

const MARGINS := preload("res://scripts/safe_margins.gd")
const THEME := preload("res://ui/theme_ember.gd")

var _move_index := -1
var _look_index := -1
var _jump_index := -1
var _origin := Vector2.ZERO
var _knob := Vector2.ZERO
var _jump_down := false
var _radius := 108.0
var _safe := Vector4(28, 18, 28, 18)


func _ready() -> void:
	THEME.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _process(_delta: float) -> void:
	var next := MARGINS.get_margins(self)
	if next != _safe:
		_safe = next
		queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if event is InputEventScreenTouch:
		_on_touch(event)
	elif event is InputEventScreenDrag:
		_on_drag(event)


func _on_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _in_jump(event.position) and _jump_index == -1:
			_jump_index = event.index
			_jump_down = true
			Touch.press_jump()
			queue_redraw()
			return
		if _in_move_zone(event.position) and _move_index == -1:
			_move_index = event.index
			_origin = event.position
			_knob = event.position
			_update_stick(event.position)
			queue_redraw()
			return
		if event.position.y > _safe.y + 108.0 and _look_index == -1:
			_look_index = event.index
		return
	_release(event.index)


func _on_drag(event: InputEventScreenDrag) -> void:
	if event.index == _move_index:
		_update_stick(event.position)
		queue_redraw()
	elif event.index == _look_index:
		Touch.add_look(event.relative)


func _release(index: int) -> void:
	if index == _move_index:
		_move_index = -1
		Touch.move = Vector2.ZERO
		queue_redraw()
	elif index == _look_index:
		_look_index = -1
	elif index == _jump_index:
		_jump_index = -1
		_jump_down = false
		queue_redraw()


func _update_stick(position: Vector2) -> void:
	var offset := position - _origin
	var length := offset.length()
	_radius = clampf(minf(size.x, size.y) * 0.13, 86.0, 140.0)
	if length > _radius and length > 0.0:
		offset = offset * (_radius / length)
	_knob = _origin + offset
	var dead := _radius * 0.18
	if offset.length() <= dead:
		Touch.move = Vector2.ZERO
		return
	var mag := clampf((offset.length() - dead) / (_radius - dead), 0.0, 1.0)
	var direction := offset.normalized()
	Touch.move = Vector2(direction.x, direction.y) * mag


func _in_move_zone(position: Vector2) -> bool:
	return position.x < size.x * 0.46 and position.y > _safe.y + 108.0


func _jump_center() -> Vector2:
	_radius = clampf(minf(size.x, size.y) * 0.13, 86.0, 140.0)
	return Vector2(size.x - _safe.z - _radius - 8.0, size.y - _safe.w - _radius - 8.0)


func _in_jump(position: Vector2) -> bool:
	return position.distance_to(_jump_center()) <= _radius * 0.92


func _draw() -> void:
	_radius = clampf(minf(size.x, size.y) * 0.13, 86.0, 140.0)
	var stick_center := Vector2(_safe.x + _radius + 18.0, size.y - _safe.w - _radius - 8.0)
	if _move_index != -1:
		stick_center = _origin
	var knob := stick_center if _move_index == -1 else _knob
	draw_circle(stick_center, _radius, Color(0.05, 0.03, 0.02, 0.38))
	draw_arc(stick_center, _radius, 0, TAU, 48, Color(0.88, 0.62, 0.28, 0.95), 3.0, true)
	draw_circle(knob, _radius * 0.38, Color(0.96, 0.62, 0.22, 0.95))
	var font := ThemeDB.fallback_font
	var move_label := "MOVE"
	var move_width := font.get_string_size(move_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
	draw_string(font, stick_center + Vector2(-move_width * 0.5, _radius + 28.0), move_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f6ecd4"))

	var jump_center := _jump_center()
	var jump_fill := Color(0.98, 0.55, 0.18, 0.95) if _jump_down else Color(0.22, 0.12, 0.08, 0.72)
	draw_circle(jump_center, _radius * 0.92, jump_fill)
	draw_arc(jump_center, _radius * 0.92, 0, TAU, 48, Color("ffd27a"), 4.0, true)
	var jump_label := "JUMP"
	var jump_size := 26
	var jump_width := font.get_string_size(jump_label, HORIZONTAL_ALIGNMENT_LEFT, -1, jump_size).x
	draw_string(
		font,
		jump_center + Vector2(-jump_width * 0.5, jump_size * 0.35),
		jump_label,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		jump_size,
		Color("fff6df")
	)
