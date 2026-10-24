extends Node

## Headless check: Jolt + mobile settings, solvable maps, a level that moves.

var _failed := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_boot")


func _boot() -> void:
	_check_settings()
	_check_maps()
	_check_scripts()
	if _failed:
		return
	Game.level_index = 0
	Game.total_coins = 0
	var level: Node = load("res://levels/level.tscn").instantiate()
	get_tree().root.add_child(level)
	_watch_level()


func _check_settings() -> void:
	var physics := str(ProjectSettings.get_setting("physics/3d/physics_engine"))
	var renderer := str(ProjectSettings.get_setting("rendering/renderer/rendering_method"))
	print("PHYSICS ", physics)
	print("RENDERER ", renderer)
	if physics != "Jolt Physics":
		_fail("physics engine is %s" % physics)
		return
	if renderer != "mobile":
		_fail("renderer is %s" % renderer)
		return


func _check_scripts() -> void:
	for path in [
		"res://ui/main_menu.gd",
		"res://ui/credits.gd",
		"res://ui/end_screen.gd",
		"res://ui/touch_controls.gd",
		"res://scripts/game.gd",
	]:
		if load(path) == null:
			_fail("script failed to load %s" % path)
			return
		print("SCRIPT ", path)


func _check_maps() -> void:
	if Game.level_count() != 5:
		_fail("expected 5 levels")
	var expect := [
		{"walk_key": true, "walk_exit": true, "jump_exit": true},
		{"walk_key": false, "walk_exit": false, "jump_exit": true},
		{"walk_key": true, "walk_exit": true, "jump_exit": true},
		{"walk_key": true, "walk_exit": true, "jump_exit": true},
		{"walk_key": true, "walk_exit": false, "jump_exit": true},
	]
	for index in Game.LEVELS.size():
		var rows: Array = Game.LEVELS[index]["rows"]
		var width := (rows[0] as String).length()
		for row in rows:
			if (row as String).length() != width:
				_fail("ragged row in level %d" % index)
				return
		var walk := _reach(rows, false)
		var jump := _reach(rows, true)
		var spec: Dictionary = expect[index]
		if walk["key"] != spec["walk_key"] or walk["exit"] != spec["walk_exit"]:
			_fail("walk reach level %d %s" % [index, walk])
			return
		if not jump["key"] or jump["exit"] != spec["jump_exit"]:
			_fail("jump reach level %d %s" % [index, jump])
			return
		print("MAP ", index, " ", Game.LEVELS[index]["title"], " coins ", _count(rows, "C"))


func _count(rows: Array, cell: String) -> int:
	var total := 0
	for row in rows:
		total += (row as String).count(cell)
	return total


func _reach(rows: Array, allow_jump: bool) -> Dictionary:
	var height := rows.size()
	var width := (rows[0] as String).length()
	var start := Vector2i.ZERO
	var key := Vector2i.ZERO
	var exit := Vector2i.ZERO
	var found_key := false
	var found_exit := false
	for y in height:
		var line: String = rows[y]
		for x in width:
			var cell := line[x]
			if cell == "S":
				start = Vector2i(x, y)
			elif cell == "K":
				key = Vector2i(x, y)
				found_key = true
			elif cell == "X":
				exit = Vector2i(x, y)
				found_exit = true
	if not found_key or not found_exit:
		_fail("map missing key or exit")
	var seen := {}
	var queue: Array[Vector2i] = [start]
	seen[_key(start)] = true
	while not queue.is_empty():
		var here: Vector2i = queue.pop_front()
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var nxt: Vector2i = here + offset
			if not _open(rows, nxt):
				if allow_jump and _pit(rows, nxt):
					var land: Vector2i = nxt + offset
					if _open(rows, land) and not seen.has(_key(land)):
						seen[_key(land)] = true
						queue.append(land)
				continue
			if seen.has(_key(nxt)):
				continue
			seen[_key(nxt)] = true
			queue.append(nxt)
	return {"key": seen.has(_key(key)), "exit": seen.has(_key(exit))}


func _key(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]


func _cell(rows: Array, cell: Vector2i) -> String:
	if cell.y < 0 or cell.y >= rows.size():
		return "#"
	var line: String = rows[cell.y]
	if cell.x < 0 or cell.x >= line.length():
		return "#"
	return line[cell.x]


func _open(rows: Array, cell: Vector2i) -> bool:
	var value := _cell(rows, cell)
	return value != "#" and value != "o"


func _pit(rows: Array, cell: Vector2i) -> bool:
	return _cell(rows, cell) == "o"


func _watch_level() -> void:
	for _i in 90:
		await get_tree().process_frame
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		_fail("no player")
	var player: Node3D = players[0]
	if get_tree().get_nodes_in_group("cinder").is_empty():
		_fail("no cinders")
	if get_tree().get_nodes_in_group("vault_key").is_empty():
		_fail("no key")
	if get_tree().get_nodes_in_group("exit_ring").is_empty():
		_fail("no exit")
	_probe_floor()
	var start_x := player.global_position.x
	Touch.move = Vector2(0, -1)
	for _i in 60:
		await get_tree().physics_frame
	Touch.move = Vector2.ZERO
	var moved := player.global_position.x - start_x
	print("MOVED ", moved, " pos ", player.global_position)
	if moved < 1.0:
		_fail("player did not walk forward")
	print("SMOKE_OK")
	get_tree().quit(0)


func _probe_floor() -> void:
	var floor: Node = load("res://scenes/floor_stone.tscn").instantiate()
	var mesh := _find_mesh(floor)
	if mesh:
		print("FLOOR_AABB ", mesh.get_aabb())
	floor.free()
	var wall: Node = load("res://scenes/wall.tscn").instantiate()
	mesh = _find_mesh(wall)
	if mesh:
		print("WALL_AABB ", mesh.get_aabb())
	wall.free()


func _find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found := _find_mesh(child)
		if found:
			return found
	return null


func _fail(reason: String) -> void:
	_failed = true
	push_error(reason)
	print("SMOKE_FAIL ", reason)
	get_tree().quit(1)
