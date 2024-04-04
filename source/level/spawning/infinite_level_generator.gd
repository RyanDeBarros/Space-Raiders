class_name InfiniteLevelGenerator
extends Node


@export_group("Exports")
@export var arena_shape: ReferenceRect
@export var enemy_spawn_zone: SpawnZoneAggregate
@export var asteroid_spawn_zone: SpawnZoneAggregate
@export var enemy_manager: EnemyManager
@export var asteroid_manager: AsteroidManager
@export_file("*.json") var initial_layout: String

@export_group("Progress Generation", "pg_")
@export var pg_max_progress := 100.0
@export var pg_progression: Curve

@export_group("Enemy Generation", "eg_")
@export var eg_spawn_rate := 3.0
@export var eg_type_distribution: Array[EnemySpawnOption]

@export_group("Asteroid Generation", "ag_")
@export var ag_spawn_rate := 4.0
@export var ag_type_distribution: Array[AsteroidSpawnOption]

var progress := 0.0
var pg_time_index := 0.0
var eg_spawn_index := 0.0
var ag_spawn_index := 0.0

@onready var pg_max_progress_inv := 1 / pg_max_progress

@onready var enemy_spawn_options: Node = $EnemySpawnOptions
@onready var asteroid_spawn_options: Node = $AsteroidSpawnOptions


func _ready() -> void:
	var file := FileAccess.open(initial_layout, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	file.close()
	call_deferred("_first_frame", json)


func _first_frame(initial_layout_json) -> void:
	_spawn_initial_layout(initial_layout_json)


func _spawn_initial_layout(initial_layout_json) -> void:
	for enemy in initial_layout_json["enemy"]:
		enemy_manager.spawn_basic_enemy(Utility.index_of(EnemyManager.BASIC_ENEMY.keys(),\
				enemy["type"]), Vector2(enemy["x"], enemy["y"]), enemy["level"])
	for asteroid in initial_layout_json["random_asteroid"]:
		asteroid_manager.spawn_random_asteroid(Vector2(asteroid["x"], asteroid["y"]))


func _process(delta: float) -> void:
	pg_time_index = minf(pg_time_index + delta, pg_max_progress)
	progress = pg_max_progress * pg_progression.sample(pg_time_index * pg_max_progress_inv)
	
	eg_spawn_index += delta
	if eg_spawn_index > eg_spawn_rate:
		eg_spawn_index = fmod(eg_spawn_index, eg_spawn_rate)
		spawn_enemy()
	
	ag_spawn_index += delta
	if ag_spawn_index > ag_spawn_rate:
		ag_spawn_index = fmod(ag_spawn_index, ag_spawn_rate)
		spawn_asteroid()


func spawn_enemy() -> void:
	var enemy_option := choose_option(enemy_spawn_options) as EnemySpawnOption
	var prog := progress * pg_max_progress_inv
	var difficulty := Math.rand_medianf(enemy_option.difficulty_lower_distribution.sample(prog),\
			enemy_option.difficulty_peak_distribution.sample(prog),\
			enemy_option.difficulty_upper_distribution.sample(prog))
	enemy_manager.spawn_carried_enemy(enemy_option.type_index,\
			enemy_spawn_zone.random_spawn_state(), roundf(difficulty))


func spawn_asteroid() -> void:
	var asteroid_option := choose_option(asteroid_spawn_options) as AsteroidSpawnOption
	asteroid_manager.spawn_carried_specific_asteroid(asteroid_spawn_zone.random_spawn_state(),\
			asteroid_option.scene)


func choose_option(options: Node) -> Node:
	return Math.select(options.get_children(), weight_fn)


func weight_fn(option: Node) -> float:
	return option.weight_distribution.sample(progress * pg_max_progress_inv)
