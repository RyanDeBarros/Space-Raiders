class_name GameOverScreen
extends Control


@onready var score_label: Label = $Panel/ScoreLabel
@onready var high_score_label: Label = $Panel/HighScoreLabel


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_packed(Scenes.TITLE_SCREEN)


func update_scores() -> void:
	score_label.text = "Score: %s" % Info.update_score()
	high_score_label.text = "High Score: %s" % Info.update_high_score()
