extends Area3D

var _label: Label3D
var _light: OmniLight3D
var _used := false


func setup(label: Label3D, light: OmniLight3D) -> void:
	_label = label
	_light = light
	if is_inside_tree():
		_refresh()


func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body)
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 1.35
	cylinder.height = 2.4
	shape.shape = cylinder
	shape.position.y = 1.2
	add_child(shape)
	Game.key_changed.connect(_refresh)
	_refresh()


func _on_body(body: Node) -> void:
	if _used or not body.is_in_group("player"):
		return
	if not Game.has_key:
		if _label:
			_label.text = "NEED THE KEY"
		return
	_used = true
	Game.complete_level()


func _refresh() -> void:
	var armed := Game.has_key
	if _label:
		_label.text = "STEP IN" if armed else "NEED THE KEY"
		_label.modulate = Color(1.0, 0.82, 0.45) if armed else Color(0.85, 0.62, 0.42)
	if _light:
		_light.light_energy = 4.0 if armed else 1.4
		_light.light_color = Color(1.0, 0.72, 0.28) if armed else Color(0.75, 0.32, 0.12)
