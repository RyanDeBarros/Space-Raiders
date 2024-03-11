extends Area2D


@export var level := 1

var minion_info: Dictionary

var active := true
var range_shoot_squared: float
var range_squared_detect: float
var angular_velocity: float
var projectile_info: Dictionary

@onready var health_component: HealthComponent = $HealthComponent
@onready var overlap_component: OverlapComponent = $OverlapComponent
@onready var cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
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


func setup_info(lvl := level) -> void:
	minion_info = Info.enemy_JSON["minion"][str(lvl)]
	overlap_component.wait_time = minion_info["collide"]["wait_time"]
	health_component.initial_health = minion_info["max_health"]
	range_shoot_squared = minion_info["combat"]["range"] ** 2
	range_squared_detect = minion_info["range"]["detect"] ** 2
	
	cooldown_timer.wait_time = Math.pm_randf(minion_info["combat"]["cooldown"],
			minion_info["combat"]["cooldown_pm"])
	projectile_info = Info.projectile_JSON[minion_info["combat"]["projectile_info_index"]]


func shoot():
	var basic_shot := Scenes.PROJECTILES["basic"].instantiate() as BasicShot
	Info.projectile_manager.add_child(basic_shot)
	basic_shot.setup_from_node(self, projectile_info, 1.57)
	basic_shot.add_to_group("enemy_owned")


func collide_player(player: Area2D) -> void:
	player.take_damage(minion_info["collide"]["damage"])
	health_component.health -= player.collide_damage


func projectile_hit(projectile: Area2D) -> void:
	health_component.health -= projectile.damage


func die() -> void:
	var explosion = Scenes.EXPLOSION_SCENE.instantiate()
	get_tree().get_first_node_in_group("explosion_manager").add_child(explosion)
	explosion.position = position
	explosion.scale *= minion_info["appearance"]["explosion_scale_mult"]
	queue_free()


func disable() -> void:
	overlap_component.disable()
	active = false
