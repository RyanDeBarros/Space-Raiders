class_name Player
extends Area2D


@export_group("Movement")
@export var max_speed := 350
@export var acceleration := 700
@export var deceleration := 700

@export_group("Camera")
@export var camera_smoothing_ratio := 0.005

@export_group("Combat")
@export var max_health := 100
@export var collide_damage := 50
@export var explosion_scale_mult := 1.0
@export var projectile_info_index := "basic"

var active := true
var dead := false

var arena_rect

var health: int:
	set(value):
		value = maxi(value, 0)
		if value < health:
			play_hit()
		health = value
		if health == 0 and not dead:
			die()

var velocity := Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite
@onready var camera_2d: Camera2D = $Camera2D
@onready var projectile_manager: Node = $ProjectileManager
@onready var projectile_info := Info.projectile_JSON[projectile_info_index] as Dictionary


func _ready() -> void:
	health = max_health
	camera_2d.position_smoothing_speed = max_speed * camera_smoothing_ratio


func _process(delta: float) -> void:
	if not active:
		return
	
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
	
	position += velocity * delta
	position.x = clampf(position.x, arena_rect.position.x, arena_rect.position.x + arena_rect.size.x)
	position.y = clampf(position.y, arena_rect.position.y, arena_rect.position.y + arena_rect.size.y)
	
	var mouse_pos_rel := get_global_mouse_position() - position
	if mouse_pos_rel.length_squared() > 16:
		rotation = mouse_pos_rel.angle() - 1.57
	
	if Input.is_action_just_pressed("shoot"):
		shoot()


func setup_camera_limits() -> void:
	arena_rect = Info.level_data["arena_rect"]
	camera_2d.limit_left = arena_rect.position.x
	camera_2d.limit_right = arena_rect.position.x + arena_rect.size.x
	camera_2d.limit_top = arena_rect.position.y
	camera_2d.limit_bottom = arena_rect.position.y + arena_rect.size.y


func shoot() -> void:
	var basic_shot := Scenes.PROJECTILES["basic"].instantiate() as BasicShot
	projectile_manager.add_child(basic_shot)
	basic_shot.setup_from_node(self, projectile_info, 1.57)
	basic_shot.add_to_group("player_owned")


func play_hit():
	#Scenes.play_explosion(Scenes.EXPLOSIONS["cloud"], position)
	pass


func die() -> void:
	dead = true
	sprite.queue_free()
	active = false
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.active = false
	
	var explosion = Scenes.EXPLOSION_SCENE.instantiate()
	get_tree().get_first_node_in_group("explosion_manager").add_child(explosion)
	explosion.position = position
	explosion.scale *= explosion_scale_mult


func projectile_hit(projectile) -> void:
	health -= projectile.damage
	projectile.hit()
