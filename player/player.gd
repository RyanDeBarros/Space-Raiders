class_name Player
extends Node2D

const BASIC_PROJECTILE := "res://txt/projectile_info/basic.json"

@export_group("Movement")
@export var max_speed := 350
@export var acceleration := 500
@export var deceleration := 500

@export_group("Camera")
@export var camera_smoothing_ratio := 0.005

@export_group("Combat")
@export var projectile_scene: PackedScene
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

var speed := 0.0
var prev_direction := Vector2.ZERO

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
	if direction:
		speed = min(speed + acceleration * delta, max_speed)
		prev_direction = direction
	else:
		speed = max(speed - deceleration * delta, 0)
		direction = prev_direction
	position += direction * speed * delta
		
	position.x = clampf(position.x, arena_rect.position.x, arena_rect.position.x + arena_rect.size.x)
	position.y = clampf(position.y, arena_rect.position.y, arena_rect.position.y + arena_rect.size.y)
	
	var mouse_pos_rel := get_global_mouse_position() - position
	if mouse_pos_rel.length_squared() > 16:
		rotation = mouse_pos_rel.angle() - 1.57
	
	if Input.is_action_just_pressed("shoot"):
		shoot()


func shoot() -> void:
	var projectile := projectile_scene.instantiate() as Projectile
	projectile_manager.add_child(projectile)
	projectile.area_2d.add_to_group("area_player_projectile")
	projectile.setup(BASIC_PROJECTILE, arena_rect)
	projectile.position = position
	projectile.rotation = rotation + 3.14


func die() -> void:
	sprite.queue_free()
	area_2d.queue_free()
	active = false
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.active = false
