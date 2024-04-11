class_name Stage
extends Node2D


@export var patrol_target_zones: Node2D

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
var modular_score := 0
var current_score: int:
	set(value):
		modular_score += value - current_score
		current_score = value
		level_overlay.display_score(current_score,\
				roundi(current_score - modular_score + current_score_threshold))
		while modular_score > current_score_threshold:
			modular_score -= roundi(current_score_threshold)
			level_up()
			if score_threshold_index < score_level_up_cap:
				score_threshold_index += 1
			current_score_threshold = compute_score_threshold()
			level_overlay.display_score(current_score,\
					roundi(current_score - modular_score + current_score_threshold))
		level_overlay.set_exp_bar_proportion(fmod(modular_score / current_score_threshold, 1))
		can_heal = modular_score >= 0.5 * current_score_threshold
		level_overlay.display_health_icon(can_heal)

var patrol_target_rects: Array[Rect2]

var can_heal := false

@onready var modulator: Node2D = $Modulator
@onready var player: Player = $Modulator/Player
@onready var arena_rect: Rect2 = $Arena/ReferenceRect.get_rect()
@onready var projectile_manager: Node2D = $Modulator/ProjectileManager
@onready var level_overlay: LevelOverlay = $Overlay/LevelOverlay
@onready var unlocker: Unlocker = $Unlocker
@onready var is_game_over := false


func _ready() -> void:
	Info.level_data["arena_rect"] = arena_rect
	Info.level_data["arena_rect_inv"] = Rect2(arena_rect.position.x, arena_rect.position.y,\
			1 / arena_rect.size.x, 1 / arena_rect.size.y)
	Info.player = player
	Info.projectile_manager = projectile_manager
	Info.main_stage = self
	
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)
	player.setup_camera_limits()
	
	player.health_changed.connect(_on_player_health_changed)
	player.shield_meter_changed.connect(_on_player_shield_meter_changed)
	player.power_meter_changed.connect(_on_player_power_meter_changed)
	level_overlay.set_shield_bar_minimum(player.shield_initiate_fraction)
	player.power_proj_icon_changed.connect(level_overlay.display_power_projectile_icon)
	player.power_minimum_meter_changed.connect(_on_player_power_minimum_meter_changed)
	player.player_died.connect(_on_player_died)
	level_overlay.quit_to_title_screen.connect(quit_to_title_screen)
	level_overlay.level_up_screen.repair.connect(_on_repair)
	level_overlay.dim.connect(_on_dim)
	
	if score_threshold_exponent < 0:
		score_threshold_exponent = compute_score_threshold_exponent()
	current_score_threshold = compute_score_threshold()
	current_score = 0
	
	for refrect in patrol_target_zones.get_children():
		if refrect is ReferenceRect:
			patrol_target_rects.push_back(refrect.get_rect())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace"):
		quit_to_title_screen()
	if event.is_action_pressed("pause") and not is_game_over\
			and not event.is_action_pressed("quit"):
		level_overlay.display_pause_screen()
	if event.is_action_pressed("toggle_minimap"):
		level_overlay.toggle_minimap()


func _on_player_health_changed(health: int) -> void:
	level_overlay.set_health_bar_proportion(float(health) / player.max_health)


func _on_player_shield_meter_changed(shield_meter: float) -> void:
	level_overlay.set_shield_bar_proportion(shield_meter)


func _on_player_power_meter_changed(power_meter: int) -> void:
	level_overlay.set_power_bar_proportion(power_meter / float(player.power_max_meter))


func _on_player_power_minimum_meter_changed(power_minimum_meter: int) -> void:
	level_overlay.set_power_bar_minimum(power_minimum_meter / float(player.power_max_meter))


func _on_enemy_destroyed(score: int) -> void:
	current_score += score


func _on_player_died() -> void:
	is_game_over = true
	Info.try_new_highscore(current_score)
	await get_tree().create_timer(1.5).timeout
	level_overlay.game_over()


func _on_repair() -> void:
	player.health += player.healing_repair_amount
	player.next_repair_amount()


func _on_dim(dim_level) -> void:
	modulator.modulate.a = dim_level


func quit_to_title_screen() -> void:
	Info.try_new_highscore(current_score)
	get_tree().change_scene_to_packed(Scenes.TITLE_SCREEN)


func level_up() -> void:
	AudioManager.play_sfx(AudioManager.SFX.success)
	level_overlay.display_level_up_screen()


func compute_score_threshold() -> float:
	return roundi(score_initial_threshold + (score_max_threshold - score_initial_threshold) *\
			((score_threshold_index / score_level_up_cap) ** score_threshold_exponent))


func compute_score_threshold_exponent() -> float:
	return log((score_intermediate_threshold - score_initial_threshold) /\
			(score_max_threshold - score_initial_threshold)) /\
			log(score_intermediate_level / score_level_up_cap)


func consume_half_exp() -> void:
	current_score -= roundi(0.5 * current_score_threshold)
