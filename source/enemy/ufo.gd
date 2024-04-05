class_name Ufo
extends Area2D


signal enemy_destroyed(score: int)


@export var level := 0
@export var score := 50
@export var audio_rel_pos_multiplier := 2.0
@export var hit_volume_db := 20.0
@export var explode_volume_db := 10.0

var active := true
var level_index: int
var angular_dir: int
var direction := Vector2.ZERO
var speed: float
var max_speed: float
var move_interval: float
var aggro_range_squared: float

@onready var sprite: Sprite2D = $Sprite
@onready var health_component: HealthComponent = $HealthComponent
@onready var overlap_component: OverlapComponent = $OverlapComponent
@onready var move_interval_timer: Timer = $MoveIntervalTimer


func _ready():
	level_index = level - 1
	add_to_group(Groups.ENEMY)
	setup_info()
	move_interval_timer.timeout.connect(_on_move_interval_end)
	angular_dir = randi_range(0, 1) * 2 - 1


func _process(delta: float) -> void:
	if active and position.distance_squared_to(Info.player.position) <= aggro_range_squared:
		speed = minf(speed + Info.ufo_info["movement"]["acceleration"] * delta, max_speed)
		if not direction:
			_on_move_interval_end()
	else:
		direction = Vector2.ZERO
		speed = maxf(speed - Info.ufo_info["movement"]["deceleration"] * delta, 0)
	position += direction * delta * speed
	rotation += Info.ufo_info["movement"]["angular_speed"] * angular_dir * delta


func _on_move_interval_end() -> void:
	max_speed = Math.rand_mediani(Info.ufo_info["speed"]["min"][level_index],\
			Info.ufo_info["speed"]["median"][level_index],\
			Info.ufo_info["speed"]["max"][level_index])
	move_interval = Math.rand_medianf_dict(Info.ufo_info["move_interval"])
	move_interval_timer.start(move_interval)
	direction = position.direction_to(Info.player.position).\
			rotated(randf() * Info.ufo_info["follow_spread"][level_index])


func setup_info() -> void:
	score = Math.rand_mediani(Info.ufo_info["score"]["min"][level_index],\
			Info.ufo_info["score"]["median"][level_index], Info.ufo_info["score"]["max"][level_index])
	overlap_component.wait_time = Info.ufo_info["collide"]["wait_time"]
	health_component.initial_health = Info.ufo_info["max_health"][level_index]
	aggro_range_squared = Info.ufo_info["aggro_range"][level_index] ** 2
	sprite.texture = load("res://assets/ships/ufos/%s.png"\
			% Info.ufo_info["appearance"]["texture"][level_index])


func collide_player(player: Area2D) -> void:
	if player:
		player.take_damage(Info.ufo_info["collide"]["damage"][level_index])
		take_damage(player.get_collide_damage())


func projectile_hit(projectile: Area2D) -> void:
	take_damage(projectile.damage)


func take_damage(damage: int) -> void:
	health_component.health -= damage
	AudioManager.play_relative_sound(AudioManager.SFX.impact_metal_1, global_position,\
			audio_rel_pos_multiplier, hit_volume_db)


func die() -> void:
	var explosion = Scenes.EXPLOSION.instantiate()
	get_tree().get_first_node_in_group(Groups.EXPLOSION_MANAGER).add_child(explosion)
	explosion.position = position
	explosion.scale *= Info.ufo_info["appearance"]["explosion_scale_mult"]
	enemy_destroyed.emit(score)
	queue_free()
	AudioManager.play_relative_sound(AudioManager.SFX.explosion, global_position,\
			audio_rel_pos_multiplier, explode_volume_db)


func disable() -> void:
	overlap_component.disable()
	active = false
	move_interval_timer.stop()
