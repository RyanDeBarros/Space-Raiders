class_name SpawnZone
extends Node2D


@export var weight := 1

@onready var zone: ReferenceRect = $Zone
@onready var target: ReferenceRect = $Target


func random_spawn_state() -> Transform2D:
	var state := Transform2D.IDENTITY
	var origin_proportion := Vector2(randf(), randf())
	state.origin = zone.position + zone.size * origin_proportion
	var target_pos := target.position + target.size * origin_proportion
	state.y = (target_pos - state.origin).normalized()
	return state
