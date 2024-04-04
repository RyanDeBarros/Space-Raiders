class_name Minion
extends Area2D


signal enemy_destroyed(score: int)


@export var level := 1
@export var score := 100
@export var audio_rel_pos_multiplier := 1.5
@export var hit_volume_db := 10.0
@export var explode_volume_db := 10.0
@export var shoot_volume_db := 10.0

var minion_info: Dictionary

var active := true
var range_shoot_squared: float
var range_squared_detect: float
var angular_velocity: float
var projectile_info: Dictionary

@onready var sprite: Sprite2D = $Sprite
@onready var health_component: HealthComponent = $HealthComponent
@onready var overlap_component: OverlapComponent = $OverlapComponent
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var burst_shooter: EnemyBurstShooter = $EnemyBurstShooter


func _ready() -> void:
	add_to_group(Groups.ENEMY)
	setup_info()
	angular_velocity = Math.pm_randf(minion_info["movement"]["orbiting_speed"],
			minion_info["movement"]["orbital_speed_pm"]) * (randi_range(0, 1) * 2 - 1)
	cooldown_timer.timeout.connect(_on_cooldown_end)


func _process(delta: float) -> void:
	var quadrance := position.distance_squared_to(Info.player.position)
	
	# Movement
	if quadrance <= range_squared_detect:
		var direction := Info.player.position.direction_to(position) as Vector2
		var range_velocity := direction * (minion_info["range"]["middle"] - sqrt(quadrance))\
				* minion_info["movement"]["speed_mult"] as Vector2
		var orbital_velocity := direction.rotated(1.57) * angular_velocity * delta
		position += range_velocity + orbital_velocity
		rotation = direction.angle() + 1.57
	
	# Combat
	if active and quadrance <= range_shoot_squared:
		if cooldown_timer.is_stopped():
			cooldown_timer.start()
	else:
		cooldown_timer.stop()


func _on_cooldown_end():
	cooldown_timer.wait_time = Math.pm_randf(minion_info["combat"]["cooldown"],
			minion_info["combat"]["cooldown_pm"])
	shoot()


func setup_info() -> void:
	minion_info = Info.enemy_JSON["minion"][str(level)]
	score = Math.rand_mediani_dict(minion_info["score"])
	sprite.texture = load("res://assets/ships/minions/%s.png"\
			% minion_info["appearance"]["texture"])
	overlap_component.wait_time = minion_info["collide"]["wait_time"]
	health_component.initial_health = minion_info["max_health"]
	range_shoot_squared = minion_info["combat"]["range"] ** 2
	range_squared_detect = minion_info["range"]["detect"] ** 2
	
	cooldown_timer.wait_time = Math.pm_randf(minion_info["combat"]["cooldown"],
			minion_info["combat"]["cooldown_pm"])
	projectile_info = Info.projectile_JSON[minion_info["combat"]["projectile_info_index"]]
	
	if minion_info["combat"]["projectile_info_index"] == "burst":
		var burst_info = minion_info["combat"]["burst_info"]
		burst_shooter.await_time = burst_info["await_time"]
		burst_shooter.num_min = burst_info["num"]["min"]
		burst_shooter.num_med = burst_info["num"]["med"]
		burst_shooter.num_max = burst_info["num"]["max"]
		burst_shooter.filename = burst_info["filename"]
		burst_shooter.colorpng = burst_info["colorpng"]
		burst_shooter.initial_speed = burst_info["initial_speed"]
		burst_shooter.acceleration = burst_info["acceleration"]
		burst_shooter.damage = burst_info["damage"]


func shoot():
	if minion_info["combat"]["projectile_info_index"] == "basic_slow":
		var basic_shot := Scenes.PROJECTILES["basic"].instantiate() as BasicShot
		basic_shot.projectile_image_dir = projectile_info["filename"]
		Info.projectile_manager.add_child(basic_shot)
		basic_shot.setup_from_node(self, projectile_info,
				minion_info["combat"]["projectile_colorpng"], 1.57)
		basic_shot.add_to_group(Groups.ENEMY_OWNED)
		basic_shot.damage = minion_info["combat"]["projectile_damage"]
		basic_shot.projectile_motion.camera_indep = true
		AudioManager.play_relative_sound(AudioManager.SFX.laser_2, global_position,\
				audio_rel_pos_multiplier, shoot_volume_db)
	elif minion_info["combat"]["projectile_info_index"] == "burst":
		burst_shooter.init_shooting()


func collide_player(player: Area2D) -> void:
	if player:
		player.take_damage(minion_info["collide"]["damage"])
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
	explosion.scale *= minion_info["appearance"]["explosion_scale_mult"]
	enemy_destroyed.emit(score)
	AudioManager.play_relative_sound(AudioManager.SFX.explosion, global_position,\
			audio_rel_pos_multiplier, explode_volume_db)
	queue_free()


func disable() -> void:
	overlap_component.disable()
	active = false
	cooldown_timer.stop()
