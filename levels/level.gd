extends Node2D


@onready var player: Player = $Player
@onready var arena_collision: CollisionShape2D = $Arena/CollisionShape2D
@onready var projectile_manager: Node2D = $ProjectileManager


func _ready() -> void:
	player.arena_rect = arena_collision.shape.get_rect()
