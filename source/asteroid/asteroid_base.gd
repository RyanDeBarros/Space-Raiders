class_name AsteroidBase
extends Area2D


@export var linear_velocity := Vector2.ZERO
@export var angular_velocity := 0.0
@export var damage := 15.0
@export var collision_rect_bounds: Rect2

var bounds: Rect2


func _ready() -> void:
	bounds = Info.arena_rect
	bounds = bounds.grow(10 + collision_rect_bounds.size.length_squared() * max(scale.x, scale.y))


func _process(delta: float) -> void:
	position += linear_velocity * delta
	rotation += angular_velocity * delta
	if not bounds.has_point(position):
		queue_free()


func collide_player(player: Area2D) -> void:
	if player:
		player.take_damage(damage)
