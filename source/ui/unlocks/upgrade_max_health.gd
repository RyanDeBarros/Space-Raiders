class_name UpgradeMaxHealth
extends "res://source/ui/unlocks/base_unlock.gd"


@export var increase: int

@onready var details: Label = $Details


func _ready() -> void:
	details.text %= increase
	data = increase
