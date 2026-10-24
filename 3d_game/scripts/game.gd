extends Node

signal coins_changed
signal key_changed
signal level_cleared
signal back_pressed

const LEVEL_SCENE := "res://levels/level.tscn"
const MENU_SCENE := "res://ui/main_menu.tscn"
const END_SCENE := "res://ui/end_screen.tscn"
const CREDITS_SCENE := "res://ui/credits.tscn"

## Cell legend: # wall, o pit, S spawn, C cinder, K key, X ember ring,
## B barrel, R crates, H chest, T table, P pillar. Anything else is floor.
const LEVELS: Array = [
	{
		"title": "Wick Yard",
		"hint": "Stick or WASD to move. Drag to look. Take the brass key to the ring.",
		"floor": "stone",
		"rows": [
			"#######",
			"#S.C..#",
			"#.B.H.#",
			"#..K.C#",
			"#....X#",
			"#######",
		],
	},
	{
		"title": "Broken Span",
		"hint": "Jump the gap. The key and the ring are on the far side.",
		"floor": "wood",
		"rows": [
			"###############",
			"#S.C.B.o.C.K.X#",
			"##.#########.##",
			"#C.........#H.#",
			"###############",
		],
	},
	{
		"title": "Banner Hall",
		"hint": "The key sits in the alcove. Walk around the inner wall.",
		"floor": "stone",
		"rows": [
			"################",
			"#S..C..P....C..#",
			"#..B...........#",
			"#......#.......#",
			"#..C..#K..R....#",
			"#......#....X..#",
			"################",
		],
	},
	{
		"title": "Cellar Run",
		"hint": "A pit cuts the cellar. Walk around it, or jump — falling sends you back.",
		"floor": "wood",
		"rows": [
			"##################",
			"#S..C..P....C....#",
			"#......B....R....#",
			"#####.############",
			"#C......o..K..X..#",
			"#....T........H..#",
			"##################",
		],
	},
	{
		"title": "Pyre Vault",
		"hint": "Last ring. The key is by the landing. Jump the gap to light it.",
		"floor": "stone",
		"rows": [
			"######################",
			"#S..C....P......C....#",
			"#....B..........R....#",
			"#..C.....####........#",
			"#........####..C.....#",
			"#..P.....####........#",
			"#....T...####........#",
			"##############.#######",
			"#C..K...C.......o.XH.#",
			"######################",
		],
	},
]

var level_index := 0
var total_coins := 0
var level_coins := 0
var level_goal := 0
var has_key := false
var cleared := false
var return_scene := MENU_SCENE


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		back_pressed.emit()


func level_count() -> int:
	return LEVELS.size()


func current() -> Dictionary:
	return LEVELS[level_index]


func is_last_level() -> bool:
	return level_index + 1 >= LEVELS.size()


func start_new_run() -> void:
	level_index = 0
	total_coins = 0
	get_tree().paused = false
	Touch.clear()
	get_tree().change_scene_to_file(LEVEL_SCENE)


func begin_level(goal: int) -> void:
	level_goal = goal
	level_coins = 0
	has_key = false
	cleared = false
	coins_changed.emit()
	key_changed.emit()


func collect_coin() -> void:
	level_coins += 1
	total_coins += 1
	coins_changed.emit()


func collect_key() -> void:
	if has_key:
		return
	has_key = true
	key_changed.emit()


func complete_level() -> void:
	if cleared or not has_key:
		return
	cleared = true
	level_cleared.emit()


func restart_level() -> void:
	total_coins -= level_coins
	get_tree().paused = false
	Touch.clear()
	get_tree().reload_current_scene()


func continue_after_clear() -> void:
	get_tree().paused = false
	Touch.clear()
	if is_last_level():
		get_tree().change_scene_to_file(END_SCENE)
	else:
		level_index += 1
		get_tree().change_scene_to_file(LEVEL_SCENE)


func quit_to_menu() -> void:
	get_tree().paused = false
	Touch.clear()
	get_tree().change_scene_to_file(MENU_SCENE)


func open_credits(back_to: String) -> void:
	return_scene = back_to
	get_tree().paused = false
	Touch.clear()
	get_tree().change_scene_to_file(CREDITS_SCENE)
