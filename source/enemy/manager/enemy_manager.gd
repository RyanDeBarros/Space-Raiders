class_name EnemyManager
extends Node2D


const BASIC_ENEMY = {
	"ufo" = preload("res://source/enemy/ufo.tscn"),
	"minion" = preload("res://source/enemy/minion.tscn"),
	"heavy" = null,
	"interceptor" = null,
}

@export var stage: Stage

@onready var directory: Node2D = $Directory


func spawn_basic_enemy(type: String, initial_position: Vector2, score := 10, level := 1) -> void:
	var enemy = BASIC_ENEMY[type].instantiate()
	enemy.level = level
	enemy.score = score
	directory.add_child(enemy)
	enemy.position = initial_position
	enemy.enemy_destroyed.connect(stage._on_enemy_destroyed)
