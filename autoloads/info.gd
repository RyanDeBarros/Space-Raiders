extends Node

var level_data = {
	"arena_rect": Rect2(0, 0, 0, 0)
}

var projectile_JSON
var enemy_JSON

var player


func _ready() -> void:
	var file = FileAccess.open("res://txt/projectile_info.json", FileAccess.READ)
	projectile_JSON = JSON.parse_string(file.get_as_text())
	file.close()
	file = FileAccess.open("res://txt/enemy_info.json", FileAccess.READ)
	enemy_JSON = JSON.parse_string(file.get_as_text())
	file.close()
