class_name EnemyManager
extends Node2D


enum BASIC_ENEMY {
	ufo,
	minion,
	interceptor,
	#heavy,
}

const _BASIC_ENEMY_list = [
	preload("res://source/enemy/ufo.tscn"),
	preload("res://source/enemy/minion.tscn"),
	preload("res://source/enemy/interceptor.tscn"),
]

@export var stage: Stage

@onready var directory: Node2D = $Directory


func _basic_enemy(type: BASIC_ENEMY, level: int) -> Area2D:
	var enemy = _BASIC_ENEMY_list[type].instantiate()
	enemy.level = level
	enemy.enemy_destroyed.connect(stage._on_enemy_destroyed)
	directory.add_child(enemy)
	return enemy


func spawn_basic_enemy(type: BASIC_ENEMY, initial_position: Vector2, level) -> void:
	var enemy := _basic_enemy(type, level)
	enemy.position = initial_position


func spawn_carried_enemy(type: BASIC_ENEMY, state: Array[Vector2], level) -> void:
	var enemy := _basic_enemy(type, level)
	var carrier := Scenes.CARRIER_COMPONENT.instantiate() as CarrierComponent
	carrier.origin = state[0]
	carrier.target = state[1]
	carrier.to_carry = enemy
	enemy.add_child(carrier)
