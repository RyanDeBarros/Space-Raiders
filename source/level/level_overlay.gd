class_name LevelOverlay
extends Control


@export_group("Health Bar", "health_bar_")
@export var health_bar_arrowhead_width: int

@export_group("Shield Bar", "shield_bar_")
@export var shield_bar_arrowhead_width: int

@export_group("Power Bar", "power_bar_")
@export var power_bar_arrowhead_width: int

var health_bar_width: float
var shield_bar_width: float
var power_bar_width: float

var shield_bar_minimum_fraction := 0.0
var power_bar_minimum_fraction := 0.0

@onready var health_bar_head: TextureRect = $HealthBar/Head
@onready var health_bar_tail: TextureRect = $HealthBar/Tail

@onready var shield_bar_head: TextureRect = $ShieldBar/Head
@onready var shield_bar_tail: TextureRect = $ShieldBar/Tail
@onready var shield_bar_minimum: TextureRect = $ShieldBar/Minimum

@onready var power_bar_head: TextureRect = $PowerBar/Head
@onready var power_bar_tail: TextureRect = $PowerBar/Tail
@onready var power_bar_minimum: TextureRect = $PowerBar/Minimum


func _ready() -> void:
	health_bar_width = health_bar_head.size.x + health_bar_tail.size.x
	shield_bar_width = shield_bar_head.size.x + shield_bar_tail.size.x
	power_bar_width = power_bar_head.size.x + power_bar_tail.size.x
	
	shield_bar_minimum_fraction = (shield_bar_minimum.position.x + shield_bar_minimum.size.x)\
			/ shield_bar_width
	power_bar_minimum_fraction = (power_bar_minimum.position.x + power_bar_minimum.size.x)\
			/ power_bar_width


func set_health_bar_proportion(fraction: float) -> void:
	health_bar_head.position.x = fraction * health_bar_width - health_bar_head.size.x
	if health_bar_head.position.x - health_bar_arrowhead_width <= 0:
		health_bar_tail.position.x = health_bar_head.position.x - health_bar_arrowhead_width
	else:
		health_bar_tail.position.x = 0


func set_shield_bar_proportion(fraction: float) -> void:
	shield_bar_head.position.x = fraction * shield_bar_width - shield_bar_head.size.x
	if shield_bar_head.position.x - shield_bar_arrowhead_width <= 0:
		shield_bar_tail.position.x = shield_bar_head.position.x - shield_bar_arrowhead_width
	else:
		shield_bar_tail.position.x = 0
	
	shield_bar_minimum.visible = shield_bar_head.position.x + shield_bar_head.size.x\
			- shield_bar_arrowhead_width > shield_bar_minimum_fraction * shield_bar_width


func set_power_bar_proportion(fraction: float) -> void:
	power_bar_head.position.x = fraction * power_bar_width - power_bar_head.size.x
	if power_bar_head.position.x - power_bar_arrowhead_width <= 0:
		power_bar_tail.position.x = power_bar_head.position.x - power_bar_arrowhead_width
	else:
		power_bar_tail.position.x = 0
	
	power_bar_minimum.visible = power_bar_head.position.x + power_bar_head.size.x\
			- power_bar_arrowhead_width > power_bar_minimum_fraction * power_bar_width


func set_shield_bar_minimum(fraction: float) -> void:
	shield_bar_minimum.position.x = fraction * shield_bar_width - shield_bar_minimum.size.x


func set_power_bar_minimum(fraction: float) -> void:
	power_bar_minimum.position.x = fraction * power_bar_width - power_bar_minimum.size.x
