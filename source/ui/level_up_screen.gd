class_name LevelUpScreen
extends Control


signal repair()

@export var parent: LevelOverlay


func _on_repair_button_pressed() -> void:
	repair.emit()
	parent.undisplay_level_up_screen()
