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
	_spawn_initial_layout(initial_layout_json)
	
	for i in range(10):
		spawn_asteroid()
		spawn_enemy()


func _spawn_initial_layout(initial_layout_json) -> void:
	for enemy in initial_layout_json["enemy"]:
		enemy_manager.spawn_basic_enemy(Utility.index_of(EnemyManager.BASIC_ENEMY.keys(),\
				enemy["type"]), Vector2(enemy["x"], enemy["y"]), enemy["level"])
	for asteroid in initial_layout_json["random_asteroid"]:
		asteroid_manager.spawn_random_asteroid(Vector2(asteroid["x"], asteroid["y"]))


func _process(delta: float) -> void:
	pass


func spawn_enemy() -> void:
	enemy_manager.spawn_carried_enemy(EnemyManager.BASIC_ENEMY.values().pick_random(),
			enemy_spawn_zone.random_spawn_state(), 1)


func spawn_asteroid() -> void:
	asteroid_manager.spawn_carried_random_asteroid(asteroid_spawn_zone.random_spawn_state())
