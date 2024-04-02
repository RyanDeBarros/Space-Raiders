extends Node

var level_data = {
	"arena_rect": Rect2(0, 0, 0, 0),
	"arena_rect_inv": Rect2(0, 0, 0, 0)
}

var projectile_JSON: Dictionary
var enemy_JSON: Dictionary

var player: Player
var projectile_manager: Node

var high_score := 0


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Load projectile info
	var file = FileAccess.open("res://config/projectile_info.json", FileAccess.READ)
	projectile_JSON = JSON.parse_string(file.get_as_text())
	file.close()
	# Load enemy info
	file = FileAccess.open("res://config/enemy_info.json", FileAccess.READ)
	enemy_JSON = JSON.parse_string(file.get_as_text())
	file.close()
	_unload_save_data()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		Info.quit()
	if event.is_action_pressed("full_screen"):
		var fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN\
				if not fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)


func _store_save_data() -> void:
	var file = FileAccess.open("user://space_raiders.save", FileAccess.WRITE)
	file.store_64(high_score)
	file.close()


func _unload_save_data() -> void:
	var file = FileAccess.open("user://space_raiders.save", FileAccess.READ)
	if file:
		high_score = file.get_64()
		file.close()


func _reset_save_data() -> void:
	high_score = 0


func quit() -> void:
	_store_save_data()
	get_tree().quit()


func try_new_highscore(score: int) -> bool:
	if score > high_score:
		high_score = score
		return true
	else:
		return false


func update_score() -> int:
	var stage := get_tree().get_first_node_in_group("main_stage") as Stage
	return stage.current_score

func update_high_score() -> int:
	try_new_highscore(update_score())
	return high_score
