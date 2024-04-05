class_name LevelUpScreen
extends Control


signal repair()

@export var parent: LevelOverlay

@onready var repair_button: Button = $RepairButton
@onready var panels_container: CenterContainer = $PanelsContainer


func _on_repair_button_pressed() -> void:
	repair.emit()
	parent.undisplay_level_up_screen()


func set_repair_amount(amount: int) -> void:
	repair_button.text = "Repair (+%s HP)" % str(amount)
