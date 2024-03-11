class_name HealthComponent
extends Node


@export var initial_health: int:
	set(value):
		initial_health = value
		health = initial_health
@export var max_health := 0
@export var die_object: Node
@export var die_callback: String

@onready var health := initial_health:
	set(value):
		if max_health > 0:
			health = clamp(value, 0, max_health)
		else:
			health = max(value, 0)
		if health == 0:
			die_object.call(die_callback)
