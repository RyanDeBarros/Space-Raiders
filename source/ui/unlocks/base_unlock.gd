class_name BaseUnlock
extends Control

@export var stage: Stage
@export var overlay: LevelOverlay

var data

@onready var select_button: Button = $SelectButton


func _on_select_button_pressed() -> void:
	stage.unlocker.call_unlock(name, data)
	stage.unlocker.unlocks_graph.use(name)
	overlay.undisplay_level_up_screen()


func callibrate_mouse_filter() -> void:
	select_button.mouse_filter = Control.MOUSE_FILTER_STOP
