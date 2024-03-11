extends Area2D


@export var level := 1

var ufo_info: Dictionary

var active := true
var angular_dir: int
var direction := Vector2.ZERO
var speed: float
var max_speed: float
var move_interval: float
var aggro_range_squared: float

@onready var health_component: HealthComponent = $HealthComponent
@onready var overlap_component: OverlapComponent = $OverlapComponent
@onready var move_interval_timer: Timer = $MoveIntervalTimer


func _ready():
	setup_info()
	move_interval_timer.timeout.connect(_on_move_interval_end)
	angular_dir = randi_range(0, 1) * 2 - 1


func _process(delta: float) -> void:
	if active and position.distance_squared_to(Info.player.position) <= aggro_range_squared:
		speed = minf(speed + ufo_info["movement"]["acceleration"] * delta, max_speed)
		if not direction:
			_on_move_interval_end()
	else:
		direction = Vector2.ZERO
		speed = maxf(speed - ufo_info["movement"]["deceleration"] * delta, 0)
	position += direction * delta * speed
	rotation += ufo_info["movement"]["angular_speed"] * angular_dir * delta


func _on_move_interval_end():
	max_speed = Math.rand_mediani(ufo_info["speed"]["min"], ufo_info["speed"]["median"],\
			ufo_info["speed"]["max"])
	move_interval = Math.rand_medianf(ufo_info["move_interval"]["min"],\
			ufo_info["move_interval"]["median"], ufo_info["move_interval"]["max"])
	move_interval_timer.start(move_interval)
	direction = position.direction_to(Info.player.position).rotated(randf() * ufo_info["follow_spread"])


func setup_info(lvl := level):
	ufo_info = Info.enemy_JSON["ufo"][str(lvl)]
	overlap_component.wait_time = ufo_info["collide"]["wait_time"]
	health_component.initial_health = ufo_info["max_health"]
	aggro_range_squared = ufo_info["aggro_range"] ** 2


func collide_player(player: Area2D):
	player.take_damage(ufo_info["collide"]["damage"])
	health_component.health -= player.collide_damage


func projectile_hit(projectile: Area2D):
	health_component.health -= projectile.damage


func die() -> void:
	var explosion = Scenes.EXPLOSION_SCENE.instantiate()
	get_tree().get_first_node_in_group("explosion_manager").add_child(explosion)
	explosion.position = position
	explosion.scale *= ufo_info["appearance"]["explosion_scale_mult"]
	queue_free()


func disable():
	overlap_component.disable()
	active = false