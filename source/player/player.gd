class_name Player
extends Area2D


signal health_changed(new_health: int)
signal shield_meter_changed(new_shield_meter: int)
signal power_meter_changed(new_power_meter: float)
signal power_minimum_meter_changed(new_power_minimum_meter: int)


@export_group("Movement")
@export var max_speed := 350
@export var acceleration := 700
@export var deceleration := 700

@export_group("Camera")
@export var camera_smoothing_ratio := 0.01

@export_group("Combat")
@export var max_health := 100
@export var collide_damage := 50
@export var explosion_scale_mult := 1.0
@export var projectile_info_color := "red"

@export_subgroup("Shield", "shield_")
@export var shield_regeneration_rate := 0.02
@export var shield_consumption_rate := 0.08
@export var shield_initiate_fraction := 0.3
@export var shield_activation_speed := 8.0
@export var shield_on_collide_mult := 0.2

@export_subgroup("Power", "power_")
@export var power_max_meter := 100.0
@export var power_meter_regeneration := 5.0
@export var power_meter_consumption_rate := 20.0


var arena_rect
var active := true
var dead := false

var health: int:
	set(value):
		health = clampi(value, 0, max_health)
		health_changed.emit(health)
		if health == 0 and not dead:
			die()

var velocity := Vector2.ZERO

var shield_on := false

var shield_meter := 1.0:
	set(value):
		shield_meter = clampf(value, 0.0, 1.0)
		shield_meter_changed.emit(shield_meter)

var power_meter: float:
	set(value):
		power_meter = clampf(value, 0, power_max_meter)
		power_meter_changed.emit(power_meter)

var is_power_meter_consuming := false

class PowerProjectile:
	var name: String
	var unlocked := false
	var packed_scene: PackedScene
	var shooter: Node
	var minimum_power: int
	var info: Dictionary
	
	func _init(name_: String, info_: Dictionary, shooter_) -> void:
		name = name_
		packed_scene = Scenes.PROJECTILES[name]
		shooter = shooter_
		info = info_
		minimum_power = info["minimum_power"]
	
	func handle_clicked() -> void:
		shooter.handle_clicked()
	
	func handle_released() -> void:
		shooter.handle_released()
	
	func start_process() -> void:
		shooter.start_process()
	
	func cancel_process() -> void:
		shooter.cancel_process()
	
	static func unlock(proj: PowerProjectile) -> void:
		proj.unlocked = true

@onready var power_projectiles := {
	"charge": PowerProjectile.new("charge", Info.projectile_JSON["charge"], $Shooter/ChargeShooter),
	"burst": PowerProjectile.new("burst", Info.projectile_JSON["burst"], $Shooter/BurstShooter),
	"bomb": PowerProjectile.new("bomb", Info.projectile_JSON["bomb"], $Shooter/ChargeShooter),
	"cannon": PowerProjectile.new("cannon", Info.projectile_JSON["cannon"], $Shooter/ChargeShooter),
	"emp": PowerProjectile.new("emp", Info.projectile_JSON["emp"], $Shooter/ChargeShooter),
	"laser": PowerProjectile.new("laser", Info.projectile_JSON["laser"], $Shooter/ChargeShooter),
}

var current_power_projectile: PowerProjectile = null:
	set(value):
		current_power_projectile = value
		if current_power_projectile:
			power_minimum_meter_changed.emit(current_power_projectile.minimum_power)


@onready var sprite: Sprite2D = $Sprite
@onready var camera: Camera2D = $Camera
@onready var shield: Sprite2D = $Shield
@onready var shield_regeneration_delay: Timer = $Shield/RegenerationDelay
@onready var projectile_info := Info.projectile_JSON["basic"] as Dictionary


func _ready() -> void:
	health = max_health
	power_meter = power_max_meter
	camera.position_smoothing_speed = max_speed * camera_smoothing_ratio
	call_deferred("first_frame")


func first_frame() -> void:
	# Testing
	#PowerProjectile.unlock(power_projectiles["charge"])
	PowerProjectile.unlock(power_projectiles["burst"])
	current_power_projectile = power_projectiles["burst"]
	current_power_projectile.start_process()


func _process(delta: float) -> void:
	if not active:
		return
	
	_update_velocity(delta)
	
	position += velocity * delta
	position.x = clampf(position.x, arena_rect.position.x,
			arena_rect.position.x + arena_rect.size.x)
	position.y = clampf(position.y, arena_rect.position.y,
			arena_rect.position.y + arena_rect.size.y)
	
	var mouse_pos_rel := get_global_mouse_position() - position
	if mouse_pos_rel.length_squared() > 16:
		rotation = mouse_pos_rel.angle() - 1.57
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	shield.position = position
	if Input.is_action_just_pressed("shield"):
		try_enable_shield()
	elif Input.is_action_just_released("shield"):
		try_disable_shield()
	_update_shield(delta)
	
	if current_power_projectile:
		if Input.is_action_just_pressed("special"):
			current_power_projectile.handle_clicked()
		elif Input.is_action_just_released("special"):
			current_power_projectile.handle_released()
	if not is_power_meter_consuming:
		power_meter += power_meter_regeneration * delta


func _update_velocity(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.x:
		velocity.x += direction.x * acceleration * delta
		velocity.x = clampf(velocity.x, -max_speed, max_speed)
	elif velocity.x > 0:
		velocity.x = max(velocity.x - deceleration * delta, 0)
	else:
		velocity.x = min(velocity.x + deceleration * delta, 0)
	if direction.y:
		velocity.y += direction.y * acceleration * delta
		velocity.y = clampf(velocity.y, -max_speed, max_speed)
	elif velocity.y > 0:
		velocity.y = max(velocity.y - deceleration * delta, 0)
	else:
		velocity.y = min(velocity.y + deceleration * delta, 0)


func setup_camera_limits() -> void:
	arena_rect = Info.level_data["arena_rect"]
	camera.limit_left = arena_rect.position.x
	camera.limit_right = arena_rect.position.x + arena_rect.size.x
	camera.limit_top = arena_rect.position.y
	camera.limit_bottom = arena_rect.position.y + arena_rect.size.y


func shoot() -> void:
	var basic_shot := Scenes.PROJECTILES["basic"].instantiate() as BasicShot
	basic_shot.projectile_image_dir = projectile_info["filename"]
	Info.projectile_manager.add_child(basic_shot)
	basic_shot.setup_from_node(self, projectile_info, "red.png", 1.57)
	basic_shot.add_to_group("player_owned")


func try_enable_shield() -> void:
	if shield_meter > shield_initiate_fraction:
		shield_on = true
		shield_meter -= shield_initiate_fraction


func try_disable_shield() -> void:
	if not shield_on: return
	shield_on = false
	shield_regeneration_delay.start()


func _update_shield(delta: float) -> void:
	if shield_on:
		shield.modulate.a = lerpf(shield.modulate.a, 1.0, shield_activation_speed * delta)
		shield_meter -= shield_consumption_rate * delta
		if shield_meter == 0.0:
			try_disable_shield()
	else:
		shield.modulate.a = lerpf(shield.modulate.a, 0.0, shield_activation_speed * delta)
		if shield_regeneration_delay.is_stopped():
			shield_meter += shield_regeneration_rate * delta


func descrease_power_meter(delta: float, factor := 1.0) -> void:
	power_meter -= factor * power_meter_consumption_rate * delta


func take_damage(damage: int) -> void:
	if not shield_on:
		health -= damage
	play_hit()


func play_hit() -> void:
	#Scenes.play_explosion(Scenes.EXPLOSIONS["cloud"], position)
	pass


func die() -> void:
	dead = true
	sprite.queue_free()
	shield.queue_free()
	active = false
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.disable()
	
	var explosion = Scenes.EXPLOSION_SCENE.instantiate()
	get_tree().get_first_node_in_group("explosion_manager").add_child(explosion)
	explosion.position = position
	explosion.scale *= explosion_scale_mult


func projectile_hit(projectile) -> void:
	take_damage(projectile.damage)


func get_collide_damage() -> int:
	return int(collide_damage * (1.0 if not shield_on else shield_on_collide_mult))
