class_name LevelOverlay
extends Control


@export var enemy_manager: EnemyManager

@export_group("Health Bar", "health_bar_")
@export var health_bar_arrowhead_width: int

@export_group("Shield Bar", "shield_bar_")
@export var shield_bar_arrowhead_width: int

@export_group("Power Bar", "power_bar_")
@export var power_bar_arrowhead_width: int

@export_group("EXP Bar", "exp_bar_")
@export var exp_bar_min_size_x: int
@export var exp_bar_max_size_x: int

var health_bar_width: float
var shield_bar_width: float
var power_bar_width: float

var shield_bar_minimum_fraction := 0.0
var power_bar_minimum_fraction := 0.0

var enemy_sensors_update_index: float

@onready var health_bar_head: TextureRect = $StatsBars/HealthBar/Head
@onready var health_bar_tail: TextureRect = $StatsBars/HealthBar/Tail

@onready var shield_bar_head: TextureRect = $StatsBars/ShieldBar/Head
@onready var shield_bar_tail: TextureRect = $StatsBars/ShieldBar/Tail
@onready var shield_bar_minimum: TextureRect = $StatsBars/ShieldBar/Minimum

@onready var power_bar_head: TextureRect = $StatsBars/PowerBar/Head
@onready var power_bar_tail: TextureRect = $StatsBars/PowerBar/Tail
@onready var power_bar_minimum: TextureRect = $StatsBars/PowerBar/Minimum

@onready var minimap: MiniMap = %MiniMap
@onready var exp_bar: NinePatchRect = $Exp/ExpRect/ExpBar
@onready var score_label: Label = $Exp/ScoreLabel

@onready var charge_shot_icon: TextureRect = %ChargeShotIcon
@onready var burst_shot_icon: Control = %BurstShotIcon
@onready var cannon_shot_icon: TextureRect = %CannonShotIcon
@onready var power_proj_icons = [charge_shot_icon, burst_shot_icon, cannon_shot_icon]


func _ready() -> void:
	enemy_sensors_update_index = minimap.enemy_sensors_update_rate
	health_bar_width = health_bar_head.size.x + health_bar_tail.size.x
	shield_bar_width = shield_bar_head.size.x + shield_bar_tail.size.x
	power_bar_width = power_bar_head.size.x + power_bar_tail.size.x
	
	shield_bar_minimum_fraction = (shield_bar_minimum.position.x + shield_bar_minimum.size.x)\
			/ shield_bar_width
	power_bar_minimum_fraction = (power_bar_minimum.position.x + power_bar_minimum.size.x)\
			/ power_bar_width


func _process(delta: float) -> void:
	if enemy_sensors_update_index != -1:
		enemy_sensors_update_index += delta
	if enemy_sensors_update_index >= minimap.enemy_sensors_update_rate:
		enemy_sensors_update_index = 0.0
		update_enemy_sensors()


func update_enemy_sensors() -> void:
	var enemy_list := Utility.get_all_children(enemy_manager.directory)
	var total_weight := float(enemy_list.size())
	var sector_nw := 0
	var sector_ne := 0
	var sector_sw := 0
	var sector_se := 0
	var sector_n := 0
	var sector_w := 0
	var sector_e := 0
	var sector_s := 0
	
	for child in enemy_list:
		if child.is_in_group("enemy"):
			if child.position.x > Info.player.position.x:
				sector_e += 1
				if child.position.y > Info.player.position.y:
					sector_se += 1
				else:
					sector_ne += 1
			else:
				sector_w += 1
				if child.position.y > Info.player.position.y:
					sector_sw += 1
				else:
					sector_nw += 1
			if child.position.y > Info.player.position.y:
				sector_s += 1
			else:
				sector_n += 1
	
	minimap.set_enemy_sensor_weights(sector_nw / total_weight,
			sector_ne / total_weight, sector_sw / total_weight,
			sector_se / total_weight, sector_n / total_weight,
			sector_w / total_weight, sector_e / total_weight,
			sector_s / total_weight)


func set_health_bar_proportion(fraction: float) -> void:
	fraction = clampf(fraction, 0.0, 1.0)
	health_bar_head.position.x = fraction * health_bar_width - health_bar_head.size.x
	if health_bar_head.position.x - health_bar_arrowhead_width <= 0:
		health_bar_tail.position.x = health_bar_head.position.x - health_bar_arrowhead_width
	else:
		health_bar_tail.position.x = 0


func set_shield_bar_proportion(fraction: float) -> void:
	fraction = clampf(fraction, 0.0, 1.0)
	shield_bar_head.position.x = fraction * shield_bar_width - shield_bar_head.size.x
	if shield_bar_head.position.x - shield_bar_arrowhead_width <= 0:
		shield_bar_tail.position.x = shield_bar_head.position.x - shield_bar_arrowhead_width
	else:
		shield_bar_tail.position.x = 0
	
	shield_bar_minimum.visible = shield_bar_head.position.x + shield_bar_head.size.x\
			- shield_bar_arrowhead_width > shield_bar_minimum_fraction * shield_bar_width


func set_power_bar_proportion(fraction: float) -> void:
	fraction = clampf(fraction, 0.0, 1.0)
	power_bar_head.position.x = fraction * power_bar_width - power_bar_head.size.x
	if power_bar_head.position.x - power_bar_arrowhead_width <= 0:
		power_bar_tail.position.x = power_bar_head.position.x - power_bar_arrowhead_width
	else:
		power_bar_tail.position.x = 0
	
	power_bar_minimum.visible = power_bar_head.position.x + power_bar_head.size.x\
			- power_bar_arrowhead_width > power_bar_minimum_fraction * power_bar_width


func set_shield_bar_minimum(fraction: float) -> void:
	fraction = clampf(fraction, 0.0, 1.0)
	shield_bar_minimum.position.x = fraction * shield_bar_width - shield_bar_minimum.size.x


func set_power_bar_minimum(fraction: float) -> void:
	fraction = clampf(fraction, 0.0, 1.0)
	power_bar_minimum.position.x = fraction * power_bar_width - power_bar_minimum.size.x


func set_exp_bar_proportion(fraction: float) -> void:
	fraction = clampf(fraction, 0.0, 1.0)
	exp_bar.size.x = lerpf(exp_bar_min_size_x, exp_bar_max_size_x, fraction)


func toggle_minimap() -> void:
	minimap.visible = not minimap.visible
	if minimap.visible:
		enemy_sensors_update_index = minimap.enemy_sensors_update_rate
	else:
		enemy_sensors_update_index = -1


func display_power_projectile_icon(name: String) -> void:
	for icon in power_proj_icons:
		icon.visible = false
	match name:
		"charge":
			charge_shot_icon.visible = true
		"burst":
			burst_shot_icon.visible = true
		"cannon":
			cannon_shot_icon.visible = true


func display_score(score: int) -> void:
	score_label.text = str(score)
