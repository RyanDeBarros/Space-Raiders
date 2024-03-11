class_name OverlapComponent
extends Node


@export var instance: Area2D
@export var callback: String
@export var target_groups: Array[String]

var wait_time := 1.0:
	set(value):
		wait_time = value
		timer.wait_time = wait_time

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.timeout.connect(_delegate)
	instance.area_entered.connect(_activate)
	instance.area_exited.connect(_deactivate)


func _delegate(area: Area2D) -> void:
	instance.call(callback, area)


func _activate(area: Area2D) -> void:
	for group in target_groups:
		if area.is_in_group(group):
			if timer.is_stopped():
				_delegate(area)
				timer.start()
			return


func _deactivate(area: Area2D) -> void:
	for group in target_groups:
		if area.is_in_group(group):
			timer.stop()
			return


func disable() -> void:
	timer.stop()
