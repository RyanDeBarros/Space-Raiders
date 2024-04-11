class_name LevelUpScreen
extends Control


signal repair()

@export var parent: LevelOverlay

@onready var repair_button: Button = $RepairButton
@onready var panels_container: HBoxContainer = $CenterContainer/PanelsContainer


func _on_repair_button_pressed() -> void:
	repair.emit()
	parent.undisplay_level_up_screen()


func set_repair_amount(amount: int) -> void:
	repair_button.text = "Repair (+%s HP)" % str(amount)


func open() -> void:
	for child in panels_container.get_children():
		child.queue_free()
	
	# delay on open
	await get_tree().create_timer(0.15).timeout
	
	var unlocks := Info.main_stage.unlocker.unlocks_graph.poll_unlock() as Array[BaseUnlock]
	for unlock in unlocks:
		unlock.overlay = parent
		panels_container.add_child(unlock)
	Utility.propogate_mouse_filter(self, Control.MOUSE_FILTER_IGNORE)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# delay on open
	await get_tree().create_timer(0.5).timeout
	
	repair_button.mouse_filter = Control.MOUSE_FILTER_STOP
	for inst in panels_container.get_children():
		inst.callibrate_mouse_filter()
