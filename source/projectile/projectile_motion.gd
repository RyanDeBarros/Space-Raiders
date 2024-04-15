class_name ProjectileMotion
extends Node2D


@export var head: Node2D
@export var initial_velocity := 400.0 * Vector2(1, 0)
@export var acceleration := 0.0
@export var angle_offset := 1.57
@export var rel_margin := 2.0
@export var lin_margin := 100.0

var camera_indep := false

@onready var velocity_dir: Vector2
@onready var velocity: float


func _ready() -> void:
	sync_velocity()


func _process(delta: float) -> void:
	head.position += velocity * delta * velocity_dir
	velocity += acceleration * delta
	if (not camera_indep and not Info.player.rigid_camera_bounds(rel_margin, lin_margin)\
			.has_point(head.position))\
			or (camera_indep and not Info.arena_rect.has_point(head.position)):
		head.queue_free()


func sync_velocity(iv := initial_velocity):
	velocity_dir = iv.normalized()
	velocity = iv.length()
	head.rotation = velocity_dir.angle() + angle_offset
