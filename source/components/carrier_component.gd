class_name CarrierComponent
extends Node


@export var origin: Vector2
@export var target: Vector2
@export var to_carry: Node2D
@export var max_weight_speed := 0.15

@onready var weight := 0.0


func _ready() -> void:
	to_carry.set_process(false)
	to_carry.position = origin


func _process(delta: float) -> void:
	weight = minf(weight + max_weight_speed * delta, 1.0)
	to_carry.position = lerp(origin, target, weight)
	if weight == 1.0:
		to_carry.set_process(true)
		queue_free()
