extends Area3D

enum Kind { COIN, KEY }

@export var kind: Kind = Kind.COIN

var _visual: Node3D
var _time := 0.0


func setup(visual: Node3D) -> void:
	_visual = visual
	add_child(visual)
	_silence(visual)


func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body)
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.05 if kind == Kind.KEY else 0.9
	shape.shape = sphere
	shape.position.y = 0.6
	add_child(shape)


func _process(delta: float) -> void:
	_time += delta
	if _visual == null:
		return
	_visual.position.y = 0.12 * sin(_time * 2.2)
	_visual.rotate_y(delta * (1.2 if kind == Kind.KEY else 0.7))


func _on_body(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if kind == Kind.COIN:
		Game.collect_coin()
	else:
		Game.collect_key()
	queue_free()


func _silence(node: Node) -> void:
	if node is CollisionObject3D:
		node.collision_layer = 0
		node.collision_mask = 0
	for child in node.get_children():
		_silence(child)
