class_name PauseScreen
extends Control


@export var parent: Node

var first_frame := true

@onready var pause_panel: Panel = $PausePanel
@onready var settings_screen: SettingsScreen = $SettingsScreen
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and not first_frame\
			and not Input.is_action_pressed("quit"):
		if settings_screen.visible:
			close_settings()
		parent.undisplay_pause_screen()
	first_frame = false


func _on_visibility_changed() -> void:
	first_frame = true
	if visible:
		update_scores()


func _on_resume_button_pressed() -> void:
	parent.undisplay_pause_screen()


func _on_quit_button_pressed() -> void:
	parent.return_to_title_screen()


func _on_settings_button_pressed() -> void:
	pause_panel.visible = false
	settings_screen.toggle(true)


func close_settings() -> void:
	settings_screen.toggle(false)
	pause_panel.visible = true


func respond_to_data_reset() -> void:
	update_scores()
	close_settings()
	_on_settings_button_pressed()


func update_scores() -> void:
	score_label.text = str(Info.update_score())
	high_score_label.text = str(Info.update_high_score())
