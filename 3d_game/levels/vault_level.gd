extends Node3D

const CELL := 4.0
const PLAYER := preload("res://addons/proto_controller/proto_controller.tscn")
const FLOOR_STONE := preload("res://scenes/floor_stone.tscn")
const FLOOR_WOOD := preload("res://scenes/floor_wood.tscn")
const WALL := preload("res://scenes/wall.tscn")
const PILLAR := preload("res://scenes/pillar.tscn")
const BARREL := preload("res://scenes/barrel.tscn")
const CRATES := preload("res://scenes/crates_stacked.tscn")
const CHEST := preload("res://scenes/chest.tscn")
const TABLE := preload("res://scenes/table_medium.tscn")
const COIN := preload("res://scenes/coin_stack.tscn")
const KEY := preload("res://scenes/key_ring.tscn")
const TORCH := preload("res://scenes/torch_mounted.tscn")
const BANNER := preload("res://scenes/banner_mounted.tscn")
const CANDLES := preload("res://scenes/candles.tscn")
const PICKUP := preload("res://scripts/pickup.gd")
const EXIT_RING := preload("res://scripts/exit_ring.gd")

var _player: CharacterBody3D
var _spawn := Vector3.ZERO
var _torch_count := 0
var _banner_count := 0


func _ready() -> void:
	_build_environment()
	var spec: Dictionary = Game.current()
	var rows: Array = spec["rows"]
	var width := (rows[0] as String).length()
	var height := rows.size()
	var coins := 0
	for row in rows:
		coins += (row as String).count("C")
	Game.begin_level(coins)
	_build_map(rows, spec.get("floor", "stone"))
	_add_void(width, height)
	_spawn_player()
	var touch_layer := CanvasLayer.new()
	touch_layer.name = "TouchLayer"
	touch_layer.layer = 15
	add_child(touch_layer)
	var touch := preload("res://ui/touch_controls.gd").new()
	touch.name = "TouchControls"
	touch_layer.add_child(touch)
	var hud := preload("res://ui/level_ui.gd").new()
	hud.name = "LevelUI"
	add_child(hud)
	hud.bind(self)


func _process(_delta: float) -> void:
	if get_tree().paused or _player == null:
		return
	if _player.global_position.y < -3.0:
		_respawn()


func _respawn() -> void:
	_player.velocity = Vector3.ZERO
	_player.global_position = _spawn
	var hud := get_node_or_null("LevelUI")
	if hud and hud.has_method("flash"):
		hud.flash("The pit drops you back.")


func _build_environment() -> void:
	var env := Environment.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.16, 0.09, 0.14)
	sky_mat.sky_horizon_color = Color(0.78, 0.36, 0.16)
	sky_mat.sky_curve = 0.12
	sky_mat.ground_bottom_color = Color(0.05, 0.03, 0.025)
	sky_mat.ground_horizon_color = Color(0.32, 0.16, 0.09)
	sky_mat.sun_angle_max = 12.0
	sky_mat.sun_curve = 0.05
	var sky := Sky.new()
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = 0.55
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.72
	env.ambient_light_sky_contribution = 1.0
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.05
	env.fog_enabled = true
	env.fog_light_color = Color(0.28, 0.14, 0.09)
	env.fog_density = 0.007
	env.fog_aerial_perspective = 0.25
	env.ssao_enabled = false
	env.glow_enabled = false
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-46, -38, 0)
	sun.light_color = Color(1.0, 0.86, 0.68)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 36.0
	sun.directional_shadow_blend_splits = false
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-18, 148, 0)
	fill.light_color = Color(0.55, 0.62, 0.78)
	fill.light_energy = 0.22
	fill.shadow_enabled = false
	add_child(fill)


func _build_map(rows: Array, floor_kind: String) -> void:
	var height := rows.size()
	for y in height:
		var line: String = rows[y]
		for x in line.length():
			var cell := line[x]
			if cell == "#" or cell == "o":
				continue
			_add_floor(x, y, floor_kind)
			_add_boundary_walls(line, rows, x, y)
			_add_cell_prop(cell, x, y)


func _add_floor(x: int, y: int, floor_kind: String) -> void:
	var visual := (FLOOR_WOOD if floor_kind == "wood" else FLOOR_STONE).instantiate()
	# KayKit floor mesh sits a few centimeters proud of y=0. Drop it onto the collider.
	visual.position = _cell(x, y) + Vector3(0, -0.05, 0)
	add_child(visual)
	var body := StaticBody3D.new()
	body.position = _cell(x, y)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(CELL, 1.0, CELL)
	shape.shape = box
	shape.position.y = -0.5
	body.add_child(shape)
	add_child(body)


func _add_boundary_walls(line: String, rows: Array, x: int, y: int) -> void:
	var edges := [
		[Vector3(-1, 0, 0), x == 0 or line[x - 1] == "#"],
		[Vector3(1, 0, 0), x == line.length() - 1 or line[x + 1] == "#"],
		[Vector3(0, 0, -1), y == 0 or (rows[y - 1] as String)[x] == "#"],
		[Vector3(0, 0, 1), y == rows.size() - 1 or (rows[y + 1] as String)[x] == "#"],
	]
	for edge in edges:
		var normal: Vector3 = edge[0]
		if not edge[1]:
			continue
		var wall := WALL.instantiate()
		var center := _cell(x, y)
		wall.position = center + normal * (CELL * 0.5)
		if absf(normal.x) > 0.5:
			wall.rotation.y = PI * 0.5
		add_child(wall)
		_decorate_wall(wall.position, -normal)


func _decorate_wall(wall_pos: Vector3, inward: Vector3) -> void:
	var slot := _torch_count + _banner_count
	if _torch_count < 5 and slot % 3 == 0:
		var torch := TORCH.instantiate()
		torch.position = wall_pos + inward * 0.15
		add_child(torch)
		if inward.length_squared() > 0.01:
			torch.look_at(torch.global_position + inward, Vector3.UP)
			torch.rotate_y(PI)
		for light in torch.find_children("*", "OmniLight3D", true):
			light.shadow_enabled = false
			light.omni_range = 7.5
			light.light_energy = 1.15
		_torch_count += 1
	elif _banner_count < 4 and slot % 3 == 1:
		var banner := BANNER.instantiate()
		banner.position = wall_pos + inward * 0.2 + Vector3(0, 1.6, 0)
		add_child(banner)
		if inward.length_squared() > 0.01:
			banner.look_at(banner.global_position + inward, Vector3.UP)
		_banner_count += 1


func _add_cell_prop(cell: String, x: int, y: int) -> void:
	var pos := _cell(x, y)
	match cell:
		"S":
			_spawn = pos + Vector3(0, 0.2, 0)
		"C":
			_add_pickup(COIN, pos, PICKUP.Kind.COIN, 1.0)
		"K":
			_add_pickup(KEY, pos + Vector3(0, 0.85, 0), PICKUP.Kind.KEY, 3.2)
		"X":
			_add_exit(pos)
		"B":
			var barrel := BARREL.instantiate()
			barrel.position = pos
			barrel.freeze = true
			barrel.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
			add_child(barrel)
		"R":
			_place(CRATES, pos)
		"H":
			_place(CHEST, pos)
		"T":
			_place(TABLE, pos)
		"P":
			_place(PILLAR, pos)


func _place(scene: PackedScene, pos: Vector3) -> void:
	var node := scene.instantiate()
	node.position = pos
	add_child(node)


func _add_pickup(scene: PackedScene, pos: Vector3, kind: int, visual_scale: float) -> void:
	var area := Area3D.new()
	area.set_script(PICKUP)
	area.kind = kind
	area.position = pos
	if kind == PICKUP.Kind.COIN:
		area.add_to_group("cinder")
	else:
		area.add_to_group("vault_key")
	var visual := scene.instantiate()
	visual.scale = Vector3.ONE * visual_scale
	area.setup(visual)
	add_child(area)
	if kind == PICKUP.Kind.KEY:
		var glow := OmniLight3D.new()
		glow.light_color = Color(1.0, 0.78, 0.35)
		glow.light_energy = 0.7
		glow.omni_range = 3.5
		glow.shadow_enabled = false
		area.add_child(glow)


func _add_exit(pos: Vector3) -> void:
	for side in [-1.15, 1.15]:
		var pillar := PILLAR.instantiate()
		pillar.position = pos + Vector3(side, 0, 0)
		pillar.scale = Vector3(0.72, 0.72, 0.72)
		add_child(pillar)
	var candles := CANDLES.instantiate()
	candles.position = pos + Vector3(0, 0, 0.7)
	add_child(candles)
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0, 1.5, 0)
	light.omni_range = 9.0
	light.shadow_enabled = false
	add_child(light)
	var label := Label3D.new()
	label.position = pos + Vector3(0, 2.6, 0)
	label.font_size = 72
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.outline_size = 12
	label.modulate = Color(1.0, 0.78, 0.4)
	label.outline_modulate = Color(0.05, 0.02, 0.01)
	add_child(label)
	var area := Area3D.new()
	area.set_script(EXIT_RING)
	area.position = pos
	area.add_to_group("exit_ring")
	area.setup(label, light)
	add_child(area)


func _add_void(width: int, height: int) -> void:
	var plane := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(220, 220)
	plane.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.025, 0.015, 0.012)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	plane.material_override = material
	plane.position = Vector3(width * CELL * 0.5, -6.0, height * CELL * 0.5)
	add_child(plane)


func _spawn_player() -> void:
	_player = PLAYER.instantiate()
	_player.can_sprint = false
	_player.can_freefly = false
	_player.base_speed = 6.0
	_player.jump_velocity = 6.4
	_player.look_speed = 0.004
	_player.position = _spawn
	_player.add_to_group("player")
	add_child(_player)
	_player.set_look_degrees(-8.0, -90.0)
	_player.get_node("Mesh").visible = false
	var camera: Camera3D = _player.get_node("Head/Camera3D")
	camera.current = true
	camera.fov = 72.0


func _cell(x: int, y: int) -> Vector3:
	return Vector3(x * CELL, 0.0, y * CELL)
