class_name TitleScreen
extends Control


@onready var modulator: Control = $Modulator
@onready var settings: Control = $Settings


func _ready() -> void:
	settings.modulate.a = 0.9


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(Scenes.SANDBOX)


func _on_settings_button_pressed() -> void:
	settings.toggle(true)
	modulator.modulate.a = 0.5


func close_settings() -> void:
	settings.toggle(false)
	modulator.modulate.a = 1.0
