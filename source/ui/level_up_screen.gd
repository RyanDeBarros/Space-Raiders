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
	for i in range(3):
		# TODO poll available unlocks
		var scene := load("res://source/ui/unlocks/upgrade_max_health.tscn")
		var inst := scene.instantiate() as UpgradeMaxHealth
		inst.stage = Info.main_stage
		inst.overlay = parent
		inst.increase = 30
		panels_container.add_child(inst)
	
	Utility.propogate_mouse_filter(self, Control.MOUSE_FILTER_IGNORE)
	mouse_filter = Control.MOUSE_FILTER_STOP
	await get_tree().create_timer(1.0).timeout
	repair_button.mouse_filter = Control.MOUSE_FILTER_STOP
	for inst in panels_container.get_children():
		inst.callibrate_mouse_filter()
