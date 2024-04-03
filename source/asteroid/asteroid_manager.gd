class_name AsteroidManager
extends Node2D


@export var max_linear_velocity := 30.0
@export var max_angular_velocity := 0.5
@export var max_scale := 1.05
@export var min_scale := 0.95


func _random_asteroid_scene() -> PackedScene:
	return Scenes.ASTEROIDS[randi_range(1, len(Scenes.ASTEROIDS))]


func spawn_random_asteroid(pos: Vector2) -> void:
	var asteroid := _random_asteroid_scene().instantiate() as AsteroidBase
	asteroid.linear_velocity = Vector2(randf_range(-max_linear_velocity, max_linear_velocity),
			randf_range(-max_linear_velocity, max_linear_velocity))
	asteroid.angular_velocity = randf_range(-max_angular_velocity, max_angular_velocity)
	add_child(asteroid)
	asteroid.position = pos
	asteroid.scale = Vector2.ONE * randf_range(min_scale, max_scale)
