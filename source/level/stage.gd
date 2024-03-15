class_name Stage
extends Node2D


@export_group("Score", "score_")
@export var score_initial_threshold := 500.0
@export var score_max_threshold := 5000.0
@export var score_level_up_cap := 100.0
## If score threshold exponent is negative, it will be computed from the intermediate level and 
## threshold. Otherwise, the intermediate level and threshold will be ignored.
@export var score_threshold_exponent := -1.0
@export var score_intermediate_level := 10.0
@export var score_intermediate_threshold := 1000.0

var score_threshold_index := 0
var current_score_threshold: float
var current_score: int:
	set(value):
		current_score = value
		if current_score > current_score_threshold:
			current_score -= int(current_score_threshold)
			level_up()
			if score_threshold_index < score_level_up_cap:
				score_threshold_index += 1
			current_score_threshold = compute_score_threshold()
		level_overlay.set_exp_bar_proportion(fmod(current_score / current_score_threshold, 1))


@onready var player: Player = $Player
@onready var arena_collision: CollisionShape2D = $Arena/CollisionShape2D
@onready var projectile_manager: Node2D = $ProjectileManager
@onready var level_overlay: LevelOverlay = $Overlay/LevelOverlay


func _ready() -> void:
	var arena_rect := arena_collision.shape.get_rect()
	Info.level_data["arena_rect"] = arena_rect
	Info.level_data["arena_rect_inv"] = Rect2(arena_rect.position.x, arena_rect.position.y,\
			1 / arena_rect.size.x, 1 / arena_rect.size.y)
	Info.player = player
	Info.projectile_manager = projectile_manager
	
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)
	player.setup_camera_limits()
	
	player.health_changed.connect(_on_player_health_changed)
	player.shield_meter_changed.connect(_on_player_shield_meter_changed)
	player.power_meter_changed.connect(_on_player_power_meter_changed)
	level_overlay.set_shield_bar_minimum(player.shield_initiate_fraction)
	player.power_minimum_meter_changed.connect(_on_player_power_minimum_meter_changed)
	
	if score_threshold_exponent < 0:
		score_threshold_exponent = compute_score_threshold_exponent()
	current_score_threshold = compute_score_threshold()
	current_score = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace"):
		get_tree().reload_current_scene()
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event.is_action_pressed("full_screen"):
		var fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN\
				if not fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	if event.is_action_pressed("toggle_minimap"):
		level_overlay.toggle_minimap()


func _on_player_health_changed(health: int) -> void:
	level_overlay.set_health_bar_proportion(float(health) / player.max_health)


func _on_player_shield_meter_changed(shield_meter: float) -> void:
	level_overlay.set_shield_bar_proportion(shield_meter)


func _on_player_power_meter_changed(power_meter: int) -> void:
	level_overlay.set_power_bar_proportion(power_meter / float(player.power_max_meter))


func _on_player_power_minimum_meter_changed(power_minimum_meter: int) -> void:
	print(power_minimum_meter / float(player.power_max_meter))
	level_overlay.set_power_bar_minimum(power_minimum_meter / float(player.power_max_meter))


func _on_enemy_destroyed(score: int) -> void:
	current_score += score


func level_up() -> void:
	print('level up!')


func compute_score_threshold() -> float:
	return int(score_initial_threshold + (score_max_threshold - score_initial_threshold) *\
			((score_threshold_index / score_level_up_cap) ** score_threshold_exponent))


func compute_score_threshold_exponent() -> float:
	return log((score_intermediate_threshold - score_initial_threshold) /\
			(score_max_threshold - score_initial_threshold)) /\
			log(score_intermediate_level / score_level_up_cap)
