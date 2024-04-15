class_name EnemyBurstShooter
extends Node


@export var enemy: Area2D
@export var await_time: float
@export var num_min: int
@export var num_med: int
@export var num_max: int
@export var filename: String
@export var colorpng: String
@export var initial_speed: float
@export var acceleration: float
@export var damage: int
@export var max_spread: float
@export var scale_mult := 1.0

var shooting := false


func _shoot_single() -> void:
	var burst_shot := Scenes.PROJECTILES["burst"].instantiate() as BasicShot
	burst_shot.projectile_image_dir = filename
	Info.projectile_manager.add_child(burst_shot)
	burst_shot.setup_from_node_nodict(enemy, initial_speed, acceleration, damage, colorpng)
	burst_shot.add_to_group(Groups.ENEMY_OWNED)
	var spread := Math.rand_medianf(-max_spread, 0, max_spread)
	burst_shot.projectile_motion.sync_velocity(burst_shot.projectile_motion.velocity *\
			burst_shot.projectile_motion.velocity_dir.rotated(spread))
	burst_shot.scale *= scale_mult
	AudioManager.play_sfx(AudioManager.SFX.laser_2)


func init_shooting() -> void:
	if not shooting:
		shooting = true
		for i in range(Math.rand_mediani(num_min, num_med, num_max)):
			_shoot_single()
			await get_tree().create_timer(await_time).timeout
		shooting = false
