extends Node


var PROJECT_VERSION := "v1.1.0"

var FULLSCREEN_ON_START: bool
var SOUNDTRACK_ON_START: bool
var OVERLAY_BORDER_VISIBLE: bool
var DEFAULT_WINDOW_SIZE_PROPORTION: float


func _init() -> void:
	var file = FileAccess.open("res://config/debug.json", FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	file.close()
	
	FULLSCREEN_ON_START = json["FULLSCREEN_ON_START"]
	DEFAULT_WINDOW_SIZE_PROPORTION = json["DEFAULT_WINDOW_SIZE_PROPORTION"]
	SOUNDTRACK_ON_START = json["SOUNDTRACK_ON_START"]
	OVERLAY_BORDER_VISIBLE = json["OVERLAY_BORDER_VISIBLE"]


func _ready() -> void:
	DisplayServer.window_set_size(DEFAULT_WINDOW_SIZE_PROPORTION * DisplayServer.screen_get_size())
	if FULLSCREEN_ON_START:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
