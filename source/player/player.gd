@icon("res://assets/ships/players/spaceShips_008.png")
class_name Player extends Area2D


signal health_changed(new_health: int)
signal shield_meter_changed(new_shield_meter: int)
signal power_meter_changed(new_power_meter: float)
signal power_minimum_meter_changed(new_power_minimum_meter: int)
signal power_proj_icon_changed(name: String)
signal player_died()


@export_group("Movement")
@export var max_speed := 350
@export var acceleration := 700
@export var deceleration := 700

@export_group("Combat")
@export var max_health := 150
@export var collide_damage := 50
@export var explosion_scale_mult := 1.0
@export var projectile_info_color := "red"
@export var defense := 1.0

@export_subgroup("Healing", "healing_")
@export var healing_rate := 6.0
@export var healing_length := 8.0
@export var healing_repair_amount := 30.0
@export var healing_repair_increase := 3.0

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

@export_group("Audio", "audio_")
@export var audio_hit_db := -1.0

var arena_rect
var active := true
var dead := false

var health: float:
	set(value):
		health = clampf(value, 0, max_health)
		health_changed.emit(health)
		if health == 0 and not dead:
			die()

var healing := false
var current_healing_time := 0.0

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

var pwp_list := ["charge", "burst", "cannon"]
var pwp_index: int:
	set(value):
		pwp_index = value
		current_power_projectile = power_projectiles[pwp_list[pwp_index]]

var current_power_projectile: PowerProjectile = null:
	set(value):
		if current_power_projectile == value:
			return
		if current_power_projectile:
			current_power_projectile.cancel_process()
		current_power_projectile = value
		if current_power_projectile:
			current_power_projectile.start_process()
			power_minimum_meter_changed.emit(current_power_projectile.minimum_power)
			power_proj_icon_changed.emit(current_power_projectile.name)


@onready var power_projectiles := {
	"charge": PowerProjectile.new("charge", Info.projectile_JSON["charge"], $Shooter/ChargeShooter),
	"burst": PowerProjectile.new("burst", Info.projectile_JSON["burst"], $Shooter/BurstShooter),
	#"bomb": PowerProjectile.new("bomb", Info.projectile_JSON["bomb"], $Shooter/ChargeShooter),
	"cannon": PowerProjectile.new("cannon", Info.projectile_JSON["cannon"], $Shooter/CannonShooter),
	#"emp": PowerProjectile.new("emp", Info.projectile_JSON["emp"], $Shooter/ChargeShooter),
	#"laser": PowerProjectile.new("laser", Info.projectile_JSON["laser"], $Shooter/ChargeShooter),
}

@onready var sprite: Sprite2D = $Sprite
@onready var camera: Camera2D = $Camera
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var shield: Sprite2D = $Shield
@onready var shield_regeneration_delay: Timer = $Shield/RegenerationDelay
@onready var projectile_info := Info.projectile_JSON["basic"] as Dictionary


func _ready() -> void:
	health = max_health
	power_meter = power_max_meter
	update_camera_smoothing()
	call_deferred("_first_frame")


func _first_frame() -> void:
	# Testing
	PowerProjectile.unlock(power_projectiles["charge"])
	PowerProjectile.unlock(power_projectiles["burst"])
	PowerProjectile.unlock(power_projectiles["cannon"])
	pwp_index = 0


func _process(delta: float) -> void:
	if not active:
		return
	
	# Movement
	_update_velocity(delta)
	position += velocity * delta
	position.x = clampf(position.x, arena_rect.position.x,
			arena_rect.position.x + arena_rect.size.x)
	position.y = clampf(position.y, arena_rect.position.y,
			arena_rect.position.y + arena_rect.size.y)
	
	# Aiming
	var mouse_pos_rel := get_global_mouse_position() - position
	if mouse_pos_rel.length_squared() > 16:
		rotation = mouse_pos_rel.angle() - 1.57
	
	# Primary shield
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	# Shield
	shield.position = position
	if Input.is_action_just_pressed("shield"):
		try_enable_shield()
	elif Input.is_action_just_released("shield"):
		try_disable_shield()
	_update_shield(delta)
	
	# Healing
	if Input.is_action_just_pressed("heal"):
		if not healing and Info.main_stage.can_heal:
			Info.main_stage.consume_half_exp()
			healing = true
		else:
			AudioManager.play_sfx(AudioManager.SFX.two_tone)
	if healing:
		health += healing_rate * delta
		current_healing_time += delta
		if current_healing_time > healing_length:
			current_healing_time = 0.0
			healing = false
	
	# Alternate fire
	if Input.is_action_just_pressed("cycle_power_up"):
		next_power_projectile()
	elif Input.is_action_just_pressed("cycle_power_down"):
		prev_power_projectile()
	
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
	basic_shot.add_to_group(Groups.PLAYER_OWNED)
	AudioManager.play_sfx(AudioManager.SFX.laser_1)


func try_enable_shield() -> void:
	if shield_meter > shield_initiate_fraction:
		shield_on = true
		shield_meter -= shield_initiate_fraction
		AudioManager.play_sfx(AudioManager.SFX.shield_up)
	else:
		AudioManager.play_sfx(AudioManager.SFX.two_tone)


func try_disable_shield() -> void:
	if not shield_on: return
	shield_on = false
	shield_regeneration_delay.start()
	AudioManager.play_sfx(AudioManager.SFX.shield_down)


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
		health -= defense * damage
		AudioManager.play_sfx(AudioManager.SFX.low_freq_explosion,\
				false, Vector2.ZERO, audio_hit_db)


func die() -> void:
	dead = true
	player_died.emit()
	sprite.queue_free()
	collision_shape_2d.queue_free()
	shield.queue_free()
	active = false
	for enemy in get_tree().get_nodes_in_group(Groups.ENEMY):
		enemy.disable()
	
	var explosion = Scenes.EXPLOSION.instantiate()
	get_tree().get_first_node_in_group(Groups.EXPLOSION_MANAGER).add_child(explosion)
	explosion.position = position
	explosion.scale *= explosion_scale_mult
	AudioManager.play_sfx(AudioManager.SFX.explosion)


func projectile_hit(projectile) -> void:
	take_damage(projectile.damage)


func get_collide_damage() -> int:
	return int(collide_damage * (1.0 if not shield_on else shield_on_collide_mult))


func next_power_projectile() -> void:
	var i := 1
	while i < len(pwp_list):
		if power_projectiles[pwp_list[(pwp_index + i) % len(pwp_list)]].unlocked:
			pwp_index = (pwp_index + i) % len(pwp_list)
			return
		i += 1


func prev_power_projectile() -> void:
	var i := 1
	while i < len(pwp_list):
		if power_projectiles[pwp_list[(pwp_index - i) % len(pwp_list)]].unlocked:
			pwp_index = (pwp_index - i) % len(pwp_list)
			return
		i += 1


func update_camera_smoothing() -> void:
	if camera:
		camera.position_smoothing_speed = max_speed * Settings.player_camera_smoothing


func camera_pos() -> Vector2:
	return camera.global_position


func rigid_camera_bounds(rel_margin: float, lin_margin: float) -> Rect2:
	var bounds := camera.get_viewport_rect()
	bounds.size.x = bounds.size.x * rel_margin / camera.zoom.x + lin_margin
	bounds.size.y = bounds.size.y * rel_margin / camera.zoom.y + lin_margin
	bounds.position += position - 0.5 * bounds.size
	return bounds


func unpause() -> void:
	if not Input.is_action_pressed("shield"):
		try_disable_shield()


func next_repair_amount() -> void:
	healing_repair_amount += healing_repair_increase
