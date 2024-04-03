class_name SpawnZoneAggregate
extends Node2D


var spawn_zones := [] as Array[SpawnZone]
var weight_sum := 0


func _ready() -> void:
	for spawn_zone in get_children():
		if spawn_zone is SpawnZone:
			spawn_zones.push_back(spawn_zone)
			weight_sum += spawn_zone.weight


func random_spawn_state() -> Array[Vector2]:
	if weight_sum == 0: return []
	var random_weight := randi_range(1, weight_sum)
	var i := 0
	while spawn_zones[i].weight < random_weight:
		random_weight -= spawn_zones[i].weight
		i += 1
	return spawn_zones[i].random_spawn_state()
