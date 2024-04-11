class_name LevelOverlay
extends Control


signal quit_to_title_screen()
signal dim(dim_level)


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

var leveling_up := false

@onready var border: Control = $Modulator/Border

@onready var health_bar_head: TextureRect = $Modulator/StatsBars/HealthBar/Head
@onready var health_bar_tail: TextureRect = $Modulator/StatsBars/HealthBar/Tail

@onready var shield_bar_head: TextureRect = $Modulator/StatsBars/ShieldBar/Head
@onready var shield_bar_tail: TextureRect = $Modulator/StatsBars/ShieldBar/Tail
@onready var shield_bar_minimum: TextureRect = $Modulator/StatsBars/ShieldBar/Minimum

@onready var power_bar_head: TextureRect = $Modulator/StatsBars/PowerBar/Head
@onready var power_bar_tail: TextureRect = $Modulator/StatsBars/PowerBar/Tail
@onready var power_bar_minimum: TextureRect = $Modulator/StatsBars/PowerBar/Minimum

@onready var modulator: Control = $Modulator
@onready var minimap: MiniMap = %MiniMap
@onready var exp_bar: NinePatchRect = %ExpBar
@onready var score_label: Label = %ScoreLabel
@onready var healable_icon: TextureRect = %HealableIcon
@onready var level_up_screen: Control = $LevelUpScreen
@onready var pause_screen: Control = $PauseScreen
@onready var game_over_screen: GameOverScreen = $GameOverScreen

@onready var charge_shot_icon: TextureRect = %ChargeShotIcon
@onready var burst_shot_icon: Control = %BurstShotIcon
@onready var cannon_shot_icon: TextureRect = %CannonShotIcon
@onready var power_proj_icons = [charge_shot_icon, burst_shot_icon, cannon_shot_icon]


func _ready() -> void:
	border.visible = Debug.OVERLAY_BORDER_VISIBLE
	enemy_sensors_update_index = minimap.enemy_sensors_update_rate
	health_bar_width = health_bar_head.size.x + health_bar_tail.size.x
	shield_bar_width = shield_bar_head.size.x + shield_bar_tail.size.x
	power_bar_width = power_bar_head.size.x + power_bar_tail.size.x
	
	shield_bar_minimum_fraction = (shield_bar_minimum.position.x + shield_bar_minimum.size.x)\
			/ shield_bar_width
	power_bar_minimum_fraction = (power_bar_minimum.position.x + power_bar_minimum.size.x)\
			/ power_bar_width
	
	Utility.propogate_mouse_filter(self, Control.MOUSE_FILTER_IGNORE)


func _process(delta: float) -> void:
	if enemy_sensors_update_index != -1:
		enemy_sensors_update_index += delta
	if enemy_sensors_update_index >= minimap.enemy_sensors_update_rate:
		enemy_sensors_update_index = 0.0
		update_enemy_sensors()


func sync_stats_bar_shaders(cutout: bool) -> void:
	if cutout:
		health_bar_head.material.set_shader_parameter("intersecting_x", Vector2(0,\
				(health_bar_tail.position.x + health_bar_tail.size.x - health_bar_head.position.x)\
				/ health_bar_head.size.x))
		shield_bar_head.material.set_shader_parameter("intersecting_x", Vector2(0,\
				(shield_bar_tail.position.x + shield_bar_tail.size.x - shield_bar_head.position.x)\
				/ shield_bar_head.size.x))
		power_bar_head.material.set_shader_parameter("intersecting_x", Vector2(0,\
				(power_bar_tail.position.x + power_bar_tail.size.x - power_bar_head.position.x)\
				/ power_bar_head.size.x))
	else:
		health_bar_head.material.set_shader_parameter("intersecting_x", Vector2(0, 0))
		shield_bar_head.material.set_shader_parameter("intersecting_x", Vector2(0, 0))
		power_bar_head.material.set_shader_parameter("intersecting_x", Vector2(0, 0))


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
		if child.is_in_group(Groups.ENEMY):
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


func display_power_projectile_icon(name_: String) -> void:
	for icon in power_proj_icons:
		icon.visible = false
	match name_:
		"charge":
			charge_shot_icon.visible = true
		"burst":
			burst_shot_icon.visible = true
		"cannon":
			cannon_shot_icon.visible = true


func display_score(score: int, next_level_score: int) -> void:
	score_label.text = "%s / %s" % [str(score), str(next_level_score)]


func display_pause_screen() -> void:
	get_tree().paused = true
	pause_screen.visible = true
	Utility.propogate_mouse_filter(pause_screen, Control.MOUSE_FILTER_STOP)
	modulator.modulate.a = 0.0
	dim.emit(0.3)
	sync_stats_bar_shaders(true)


func undisplay_pause_screen() -> void:
	pause_screen.visible = false
	Info.player.unpause()
	Utility.propogate_mouse_filter(pause_screen, Control.MOUSE_FILTER_IGNORE)
	if not leveling_up:
		dim.emit(1.0)
		modulator.modulate.a = 1.0
		get_tree().paused = false
		sync_stats_bar_shaders(false)


func return_to_title_screen() -> void:
	get_tree().paused = false
	quit_to_title_screen.emit()


func game_over() -> void:
	game_over_screen.update_scores()
	game_over_screen.visible = true
	Utility.propogate_mouse_filter(game_over_screen, Control.MOUSE_FILTER_STOP)
	modulator.modulate.a = 0.0


func display_health_icon(healable: bool) -> void:
	healable_icon.modulate.v = 1 if healable else 0


func display_level_up_screen() -> void:
	get_tree().paused = true
	leveling_up = true
	level_up_screen.set_repair_amount(Info.player.healing_repair_amount)
	level_up_screen.visible = true
	Utility.propogate_mouse_filter(level_up_screen, Control.MOUSE_FILTER_STOP)
	modulator.modulate.a = 0.6
	dim.emit(0.3)
	sync_stats_bar_shaders(true)
	level_up_screen.open()


func undisplay_level_up_screen() -> void:
	get_tree().paused = false
	Info.player.unpause()
	leveling_up = false
	level_up_screen.visible = false
	Utility.propogate_mouse_filter(level_up_screen, Control.MOUSE_FILTER_IGNORE)
	modulator.modulate.a = 1.0
	dim.emit(1.0)
	sync_stats_bar_shaders(false)
