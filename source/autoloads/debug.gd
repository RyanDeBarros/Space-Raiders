extends Node


var SOUNDTRACK_ON_START: bool
var OVERLAY_BORDER_VISIBLE: bool


func _init() -> void:
	var file = FileAccess.open("res://config/debug.json", FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	file.close()
	
	SOUNDTRACK_ON_START = json["SOUNDTRACK_ON_START"]
	OVERLAY_BORDER_VISIBLE = json["OVERLAY_BORDER_VISIBLE"]
