extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("explode")
	await animation_player.animation_finished
	queue_free()
