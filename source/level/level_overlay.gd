class_name LevelOverlay
extends Control


@export_group("Health Bar", "health_bar_")
@export var health_bar_head_trx_threshold: int
@export var health_bar_initial_x: int

@onready var health_bar_head: TextureRect = $HealthBar/Head
@onready var health_bar_tail: TextureRect = $HealthBar/Tail



func set_health_bar_proportion(fraction: float):
	var translate := (1 - fraction) * (health_bar_head.size.x + health_bar_tail.size.x)
	health_bar_head.position.x = health_bar_initial_x + health_bar_tail.size.x - translate
	if translate > health_bar_head_trx_threshold:
		health_bar_tail.position.x = health_bar_initial_x - translate + health_bar_head_trx_threshold
