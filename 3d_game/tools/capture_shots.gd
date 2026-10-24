extends Node

var _dir := ""
var _step := 0
var _frames := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_dir = OS.get_environment("SHOT_DIR")
	if _dir.is_empty():
		_dir = ProjectSettings.globalize_path("res://../docs/screenshots")
	DirAccess.make_dir_recursive_absolute(_dir)
	call_deferred("_boot")


func _boot() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(2400, 1080))
	var tree := get_tree()
	reparent(tree.root)
	tree.current_scene = null
	tree.change_scene_to_file("res://ui/main_menu.tscn")
	_step = 1


func _process(_delta: float) -> void:
	_frames += 1
	if _step == 1 and _frames == 45:
		_capture("menu.png")
	elif _step == 1 and _frames == 50:
		Game.start_new_run()
		_step = 2
		_frames = 0
	elif _step == 2 and _frames == 60:
		_capture("gameplay.png")
	elif _step == 2 and _frames == 70:
		print("SHOTS_OK")
		get_tree().quit(0)


func _capture(file_name: String) -> void:
	RenderingServer.frame_post_draw.connect(_save.bind(file_name), CONNECT_ONE_SHOT)


func _save(file_name: String) -> void:
	var image := get_tree().root.get_viewport().get_texture().get_image()
	if image == null or image.get_width() < 2:
		push_error("empty screenshot")
		get_tree().quit(1)
		return
	var peak := 0
	for y in range(0, image.get_height(), 24):
		for x in range(0, image.get_width(), 24):
			var color := image.get_pixel(x, y)
			peak = maxi(peak, int(maxf(color.r, maxf(color.g, color.b)) * 255.0))
	var path := _dir.path_join(file_name)
	var err := image.save_png(path)
	print("SHOT ", path, " ", image.get_width(), "x", image.get_height(), " peak ", peak, " err ", err)
	if err != OK or peak < 12:
		push_error("screenshot failed")
		get_tree().quit(1)
