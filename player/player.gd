class_name Player
extends Node2D


@export_group("Movement")
@export var max_speed := 350
@export var acceleration := 700
@export var deceleration := 700

@export_group("Camera")
@export var camera_smoothing_ratio := 0.005

@export_group("Combat")
@export var max_health := 100
@export var collide_damage := 50

var active := true

var arena_rect: Rect2i:
	set(value):
		arena_rect = value
		camera_2d.limit_left = arena_rect.position.x
		camera_2d.limit_right = arena_rect.position.x + arena_rect.size.x
		camera_2d.limit_top = arena_rect.position.y
		camera_2d.limit_bottom = arena_rect.position.y + arena_rect.size.y

var health: int:
	set(value):
		health = maxi(value, 0)
		if health == 0:
			die()


var velocity := Vector2.ZERO

var projectile_manager: Node2D

@onready var sprite: Sprite2D = $Sprite
@onready var area_2d: Area2D = $Area2D
@onready var camera_2d: Camera2D = $Camera2D


func _ready() -> void:
	health = max_health
	camera_2d.position_smoothing_speed = max_speed * camera_smoothing_ratio
	projectile_manager = get_tree().get_first_node_in_group("projectile_manager")
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)


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


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("area_enemy_projectile"):
		var proj := area.get_parent() as Projectile
		health -= proj.damage
		proj.hit()


func shoot() -> void:
	var projectile := Scenes.PROJECTILE_SCENE.instantiate() as Projectile
	projectile_manager.add_child(projectile)
	projectile.area_2d.add_to_group("area_player_projectile")
	projectile.setup(Scenes.PLAYER_PROJECTILE_CONFIG["basic"])
	projectile.position = position
	projectile.rotation = rotation + 3.14


func die() -> void:
	sprite.queue_free()
	area_2d.queue_free()
	active = false
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.active = false
