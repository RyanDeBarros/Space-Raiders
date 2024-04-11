class_name BaseUnlock
extends Control

@export var stage: Stage
@export var overlay: LevelOverlay
@export var unlock_name: String

var data

@onready var select_button: Button = $SelectButton


func _on_select_button_pressed() -> void:
	stage.unlocker.call_unlock(unlock_name, data)
	stage.unlocker.unlocks_graph.use(unlock_name)
	overlay.undisplay_level_up_screen()


func callibrate_mouse_filter() -> void:
	select_button.mouse_filter = Control.MOUSE_FILTER_STOP
