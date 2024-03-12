class_name LevelOverlay
extends Control


@export_group("Health Bar", "health_bar_")
@export var health_bar_arrowhead_width: int

@onready var health_bar_head: TextureRect = $HealthBar/Head
@onready var health_bar_tail: TextureRect = $HealthBar/Tail

@export_group("Shield Bar", "shield_bar_")
@export var shield_bar_arrowhead_width: int

@onready var shield_bar_head: TextureRect = $ShieldBar/Head
@onready var shield_bar_tail: TextureRect = $ShieldBar/Tail

@export_group("Power Bar", "power_bar_")
@export var power_bar_arrowhead_width: int

@onready var power_bar_head: TextureRect = $PowerBar/Head
@onready var power_bar_tail: TextureRect = $PowerBar/Tail


func set_health_bar_proportion(fraction: float) -> void:
	var translate := (1 - fraction) * (health_bar_head.size.x + health_bar_tail.size.x)
	health_bar_head.position.x = health_bar_tail.size.x - translate
	if health_bar_head.position.x - health_bar_arrowhead_width <= 0:
		health_bar_tail.position.x = health_bar_head.position.x - health_bar_arrowhead_width


func set_shield_bar_proportion(fraction: float) -> void:
	var translate := (1 - fraction) * (shield_bar_head.size.x + shield_bar_tail.size.x)
	shield_bar_head.position.x = shield_bar_tail.size.x - translate
	if shield_bar_head.position.x - shield_bar_arrowhead_width <= 0:
		shield_bar_tail.position.x = shield_bar_head.position.x - shield_bar_arrowhead_width


func set_power_bar_proportion(fraction: float) -> void:
	var translate := (1 - fraction) * (power_bar_head.size.x + power_bar_tail.size.x)
	power_bar_head.position.x = power_bar_tail.size.x - translate
	if power_bar_head.position.x - power_bar_arrowhead_width <= 0:
		power_bar_tail.position.x = power_bar_head.position.x - power_bar_arrowhead_width


func set_shield_bar_minimum(fraction: float) -> void:
	pass
	

func set_power_bar_minimum(fraction: float) -> void:
	pass
