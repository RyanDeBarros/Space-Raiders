@icon("res://assets/ships/interceptors/enemyRed1.png")
class_name Interceptor extends Area2D


signal enemy_destroyed(score: int)


@export var level := 0
@export var score := 50
@export var audio_rel_pos_multiplier := 2.0
@export var hit_volume_db := 10.0
@export var explode_volume_db := 10.0
@export var shoot_volume_db := 10.0
@export var overshoot_curve: Curve
@export var offscreen_margin := 100.0

var active := true
var level_index: int
var intercept_range_squared: float
var stalking_range_squared: float
var patrol_target_rect: Rect2
var patrol_target_point: Vector2

var proj_dict: Dictionary
var projectile_info: Dictionary

var can_shoot := false
var movement_info: Dictionary
var overshooting := false
var overshoot_curve_area_inv: float
var overshoot_max_weight: float
var overshoot_weight: float
var overshoot_direction: Vector2
var overshoot_distance: float

@onready var sprite: Sprite2D = $Sprite
@onready var health_component: HealthComponent = $HealthComponent
@onready var overlap_component: OverlapComponent = $OverlapComponent
@onready var burst_shooter: EnemyBurstShooter = $EnemyBurstShooter


func _ready() -> void:
	level_index = level - 1
	add_to_group(Groups.ENEMY)
	_setup_info()
	overshoot_max_weight = movement_info["max_weight"][level_index]
	overshoot_weight = overshoot_max_weight + movement_info["rest_weight"][level_index]
	overshoot_curve_area_inv = 1.25
	call_deferred("_first_frame")


func _first_frame() -> void:
	next_patrol_target()


func _process(delta: float) -> void:
	var quadrance := position.distance_squared_to(Info.player.position)
	
	# Movement
	if quadrance < intercept_range_squared or overshooting:
		if overshoot_weight < overshoot_max_weight:
			overshooting = true
			if Info.is_valid_movement(position, overshoot_direction, offscreen_margin):
				position += overshoot_direction * delta * overshoot_distance * overshoot_curve_area_inv\
						* overshoot_curve.sample(overshoot_weight / overshoot_max_weight)\
						* movement_info["overshoot_mult"] / overshoot_max_weight
			overshoot_weight += delta
		elif overshoot_weight < overshoot_max_weight + movement_info["rest_weight"][level_index]:
			if can_shoot:
				shoot()
				can_shoot = false
			overshoot_weight += delta
		else:
			overshooting = false
			overshoot_distance = position.distance_to(Info.player.position)
			overshoot_direction = (Info.player.position - position).normalized()
			overshoot_weight = 0.0
			can_shoot = true
		rotation = (Info.player.position - position).angle() - 1.57
	elif quadrance < stalking_range_squared:
		position += (Info.player.position - position).normalized()\
				* movement_info["stalking_speed"] * delta
		overshoot_weight = overshoot_max_weight
		rotation = (Info.player.position - position).angle() - 1.57
	else:
		overshoot_weight = overshoot_max_weight
		var delta_angle := Math.angle_diff(rotation + 1.57,\
				(patrol_target_point - position).angle())
		rotation += minf(delta * Info.interceptor_info["patrol"]["turn_rate"], delta_angle)
		var delta_move := patrol_target_point - position
		position += minf(delta * Info.interceptor_info["patrol"]["move_rate_qdr"],\
				delta_move.length_squared()) * delta_move.normalized()
		if delta_move.length_squared() < Info.interceptor_info["patrol"]["threshold_qdr"]:
			next_patrol_target()


func _setup_info() -> void:
	score = Math.rand_mediani(Info.interceptor_info["score"]["min"][level_index],\
			Info.interceptor_info["score"]["median"][level_index],\
			Info.interceptor_info["score"]["max"][level_index])
	sprite.texture = load("res://assets/ships/interceptors/%s.png"\
			% Info.interceptor_info["appearance"]["texture"][level_index])
	overlap_component.wait_time = Info.interceptor_info["collide"]["wait_time"]
	health_component.initial_health = Info.interceptor_info["max_health"][level_index]
	intercept_range_squared = Info.interceptor_info["intercept_range"][level_index] ** 2
	stalking_range_squared = Info.interceptor_info["stalking_range"][level_index] ** 2
	movement_info = Info.interceptor_info["movement"]
	
	proj_dict = Info.interceptor_info["combat"]["projectile"][level_index]
	projectile_info = Info.projectile_JSON[proj_dict["info_index"]]
	
	if proj_dict["info_index"] == "burst":
		burst_shooter.await_time = proj_dict["await_time"]
		burst_shooter.num_min = proj_dict["num"]["min"]
		burst_shooter.num_med = proj_dict["num"]["med"]
		burst_shooter.num_max = proj_dict["num"]["max"]
		burst_shooter.filename = proj_dict["filename"]
		burst_shooter.colorpng = proj_dict["colorpng"]
		burst_shooter.initial_speed = proj_dict["initial_speed"]
		burst_shooter.acceleration = proj_dict["acceleration"]
		burst_shooter.damage = proj_dict["damage"]
		burst_shooter.max_spread = proj_dict["max_spread"]
		burst_shooter.scale_mult = proj_dict["scale_mult"]


func shoot():
	if proj_dict["info_index"] == "basic_slow":
		var basic_shot := Scenes.PROJECTILES["basic"].instantiate() as BasicShot
		basic_shot.projectile_image_dir = projectile_info["filename"]
		Info.projectile_manager.add_child(basic_shot)
		basic_shot.setup_from_node(self, projectile_info, proj_dict["colorpng"])
		basic_shot.add_to_group(Groups.ENEMY_OWNED)
		basic_shot.damage = proj_dict["damage"]
		basic_shot.projectile_motion.camera_indep = true
		basic_shot.projectile_motion.velocity = proj_dict["initial_speed"]
		basic_shot.scale *= proj_dict["scale_mult"]
		AudioManager.play_relative_sound(AudioManager.SFX.laser_2, global_position,\
				audio_rel_pos_multiplier, shoot_volume_db)
	elif proj_dict["info_index"] == "burst":
		burst_shooter.init_shooting()


func collide_player(player: Area2D) -> void:
	if is_instance_valid(player):
		player.take_damage(Info.interceptor_info["collide"]["damage"][level_index])
		take_damage(player.get_collide_damage())


func projectile_hit(projectile: Area2D) -> void:
	take_damage(projectile.damage)


func take_damage(damage: int) -> void:
	health_component.health -= damage
	AudioManager.play_relative_sound(AudioManager.SFX.impact_metal_1,\
			global_position, audio_rel_pos_multiplier, hit_volume_db)


func die() -> void:
	var explosion = Scenes.EXPLOSION.instantiate()
	get_tree().get_first_node_in_group(Groups.EXPLOSION_MANAGER).add_child(explosion)
	explosion.position = position
	explosion.scale *= Info.interceptor_info["appearance"]["explosion_scale_mult"]
	enemy_destroyed.emit(score)
	AudioManager.play_relative_sound(AudioManager.SFX.explosion, global_position,\
			audio_rel_pos_multiplier, explode_volume_db)
	queue_free()


func disable() -> void:
	overlap_component.disable()
	active = false


func next_patrol_target() -> void:
	var target_rects := Info.main_stage.patrol_target_rects.duplicate() as Array[Rect2]
	target_rects.erase(patrol_target_rect)
	patrol_target_rect = target_rects.pick_random()
	patrol_target_point.x = patrol_target_rect.position.x + patrol_target_rect.size.x * randf()
	patrol_target_point.y = patrol_target_rect.position.y + patrol_target_rect.size.y * randf()
