class_name AsteroidManager
extends Node2D


@export var max_linear_velocity := 30.0
@export var max_angular_velocity := 0.5
@export var max_scale := 1.05
@export var min_scale := 0.95


func _random_asteroid_scene() -> PackedScene:
	return Scenes.ASTEROIDS[randi_range(1, len(Scenes.ASTEROIDS))]


func _basic_asteroid(scene: PackedScene) -> AsteroidBase:
	var asteroid := scene.instantiate() as AsteroidBase
	asteroid.angular_velocity = randf_range(-max_angular_velocity, max_angular_velocity)
	asteroid.scale = Vector2.ONE * randf_range(min_scale, max_scale)
	add_child(asteroid)
	return asteroid


func _random_basic_asteroid() -> AsteroidBase:
	return _basic_asteroid(_random_asteroid_scene())


func spawn_random_asteroid(pos: Vector2) -> void:
	var asteroid := _random_basic_asteroid()
	asteroid.linear_velocity = Vector2(randf_range(-max_linear_velocity, max_linear_velocity),
			randf_range(-max_linear_velocity, max_linear_velocity))
	asteroid.position = pos


func spawn_carried_random_asteroid(state: Array[Vector2]) -> void:
	var asteroid := _random_basic_asteroid()
	asteroid.linear_velocity = max_linear_velocity * (state[1] - state[0]).normalized().\
			rotated(randf_range(-0.8, 0.8))
	var carrier := Scenes.CARRIER_COMPONENT.instantiate() as CarrierComponent
	carrier.origin = state[0]
	carrier.target = state[1]
	carrier.to_carry = asteroid
	asteroid.add_child(carrier)


func spawn_carried_specific_asteroid(state: Array[Vector2], scene: PackedScene):
	var asteroid := _basic_asteroid(scene)
	asteroid.linear_velocity = max_linear_velocity * (state[1] - state[0]).normalized().\
			rotated(randf_range(-0.8, 0.8))
	var carrier := Scenes.CARRIER_COMPONENT.instantiate() as CarrierComponent
	carrier.origin = state[0]
	carrier.target = state[1]
	carrier.to_carry = asteroid
	asteroid.add_child(carrier)
