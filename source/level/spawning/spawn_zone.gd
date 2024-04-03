class_name SpawnZone
extends Node2D


@export var weight := 1

@onready var zone: ReferenceRect = $Zone
@onready var target: ReferenceRect = $Target


func random_spawn_state() -> Array[Vector2]:
	var state := [] as Array[Vector2]
	var rect_proportion := Vector2(randf(), randf())
	state.push_back(zone.position + zone.size * rect_proportion)
	state.push_back(target.position + target.size * rect_proportion)
	return state
