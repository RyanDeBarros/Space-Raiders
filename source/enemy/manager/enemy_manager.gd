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


func _ready() -> void:
	spawn_basic_enemy("ufo", Vector2(-470, -200), 50)
	spawn_basic_enemy("ufo", Vector2(-160, -310), 50)
	spawn_basic_enemy("ufo", Vector2(560, -300), 50)
	spawn_basic_enemy("ufo", Vector2(400, 470), 50)
	spawn_basic_enemy("ufo", Vector2(-880, 345), 50)
	spawn_basic_enemy("minion", Vector2(-590, 290), 120)
	spawn_basic_enemy("minion", Vector2(-200, 560), 120)
	spawn_basic_enemy("minion", Vector2(300, -490), 120)
	spawn_basic_enemy("minion", Vector2(700, 0), 120)


func spawn_basic_enemy(type: String, initial_position: Vector2, score := 10, level := 1) -> void:
	var enemy = BASIC_ENEMY[type].instantiate()
	enemy.level = level
	enemy.score = score
	directory.add_child(enemy)
	enemy.position = initial_position
	enemy.enemy_destroyed.connect(stage._on_enemy_destroyed)
