class_name BaseUnlock
extends Control


@export var stage: Stage
@export var overlay: LevelOverlay
@export var method_name: String
@export var increase: int

var data

@onready var select_button: Button = $SelectButton
@onready var details: Label = $Details


func _ready() -> void:
	details.text %= data


func _on_select_button_pressed() -> void:
	stage.call(method_name, data)
	overlay.undisplay_level_up_screen()


func callibrate_mouse_filter() -> void:
	select_button.mouse_filter = Control.MOUSE_FILTER_STOP
