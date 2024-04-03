class_name InfiniteLevelGenerator
extends Node


@export var arena_shape: ReferenceRect
@export var enemy_spawn_zone: SpawnZoneAggregate
@export var asteroid_spawn_zone: SpawnZoneAggregate
@export var enemy_manager: EnemyManager
@export var asteroid_manager: AsteroidManager
@export_file("*.json") var initial_layout: String


func _ready() -> void:
	var file := FileAccess.open(initial_layout, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	file.close()
	call_deferred("_first_frame", json)


func _first_frame(initial_layout_json) -> void:
	for enemy in initial_layout_json["enemy"]:
		enemy_manager.spawn_basic_enemy(enemy["type"],\
				Vector2(enemy["x"], enemy["y"]), enemy["score"], enemy["level"])
	for asteroid in initial_layout_json["random_asteroid"]:
		asteroid_manager.spawn_random_asteroid(Vector2(asteroid["x"], asteroid["y"]))


func _process(delta: float) -> void:
	pass
