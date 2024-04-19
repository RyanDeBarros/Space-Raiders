extends Node


const SAVE_VERSION_UID := 0b01001101010010100100100100001001
const SETTINGS_VERSION_UID := 0b10100100001000011000101000010110

var arena_rect := Rect2(0, 0, 0, 0)
var arena_rect_inv := Rect2(0, 0, 0, 0)

var unlocks_graph: Array
var projectile_JSON: Dictionary
var enemy_JSON: Dictionary
var ufo_info: Dictionary
var minion_info: Dictionary
var interceptor_info: Dictionary

var main_stage: Stage
var player: Player
var projectile_manager: Node

var high_score := 0

var player_camera_smoothing := 0.01:
	set(value):
		player_camera_smoothing = value
		if is_instance_valid(player):
			player.update_camera_smoothing()


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Load unlocks graph
	var file = FileAccess.open("res://config/unlocks_graph.json", FileAccess.READ)
	unlocks_graph = JSON.parse_string(file.get_as_text())
	file.close()
	# Load projectile info
	file = FileAccess.open("res://config/projectile_info.json", FileAccess.READ)
	projectile_JSON = JSON.parse_string(file.get_as_text())
	file.close()
	# Load enemy info
	file = FileAccess.open("res://config/enemy_info.json", FileAccess.READ)
	enemy_JSON = JSON.parse_string(file.get_as_text())
	file.close()
	ufo_info = enemy_JSON["ufo"]
	minion_info = enemy_JSON["minion"]
	interceptor_info = enemy_JSON["interceptor"]
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
	var file = FileAccess.open("user://score_%s.save" % Debug.PROJECT_VERSION, FileAccess.WRITE)
	file.store_32(SAVE_VERSION_UID)
	
	file.store_64(high_score)
	
	file.close()
	file = FileAccess.open("user://settings_%s.save" % Debug.PROJECT_VERSION, FileAccess.WRITE)
	file.store_32(SETTINGS_VERSION_UID)
	
	if AudioManager.mute_music:
		file.store_float(AudioManager.music_muted_db)
	else:
		file.store_float(AudioManager.volume_db_music)
	if AudioManager.mute_sfx:
		file.store_float(AudioManager.sfx_muted_db)
	else:
		file.store_float(AudioManager.volume_db_sfx)
	
	file.store_float(player_camera_smoothing)
	file.store_var(Debug.OVERLAY_BORDER_VISIBLE)
	
	file.close()


func _unload_save_data() -> void:
	var file = FileAccess.open("user://score_%s.save"  % Debug.PROJECT_VERSION, FileAccess.READ)
	if file and file.get_32() == SAVE_VERSION_UID:
		high_score = file.get_64()
		file.close()
	
	file = FileAccess.open("user://settings_%s.save" % Debug.PROJECT_VERSION, FileAccess.READ)
	if file and file.get_32() == SETTINGS_VERSION_UID:
		var db = file.get_float()
		if db == AudioManager.music_muted_db:
			AudioManager.mute_music = true
		else:
			AudioManager.mute_music = false
			AudioManager.volume_db_music = db
		db = file.get_float()
		if db == AudioManager.sfx_muted_db:
			AudioManager.mute_sfx = true
		else:
			AudioManager.mute_sfx = false
			AudioManager.volume_db_sfx = db
		
		player_camera_smoothing = file.get_float()
		Debug.OVERLAY_BORDER_VISIBLE = file.get_var()
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
	var stage := get_tree().get_first_node_in_group(Groups.MAIN_STAGE) as Stage
	return stage.current_score


func update_high_score() -> int:
	try_new_highscore(update_score())
	return high_score


func is_valid_movement(position: Vector2, direction: Vector2, margin := 0.0) -> bool:
	if position.x < arena_rect.position.x - margin and direction.x < 0:
		return false
	if position.x > arena_rect.position.x + arena_rect.size.x + margin and direction.x > 0:
		return false
	if position.y < arena_rect.position.y - margin and direction.y < 0:
		return false
	if position.y > arena_rect.position.y + arena_rect.size.y + margin and direction.y > 0:
		return false
	return true
