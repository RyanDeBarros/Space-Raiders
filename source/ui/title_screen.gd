class_name TitleScreen
extends Control


@onready var modulator: Control = $Modulator
@onready var high_score_label: Label = %HighScoreLabel
@onready var settings_screen: SettingsScreen = $SettingsScreen


func _ready() -> void:
	settings_screen.modulate.a = 0.9
	high_score_label.text = "High Score: %s" % Info.high_score


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(Scenes.SANDBOX)


func _on_settings_screen_button_pressed() -> void:
	settings_screen.toggle(true)
	modulator.modulate.a = 0.5


func close_settings_screen() -> void:
	settings_screen.toggle(false)
	modulator.modulate.a = 1.0


func respond_to_data_reset() -> void:
	get_tree().reload_current_scene()
