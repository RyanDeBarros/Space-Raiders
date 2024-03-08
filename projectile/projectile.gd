class_name Projectile
extends Node2D


var global_bounds: Rect2i
var outside_margin := 100.0

var speed := 500.0
var damage := 35

@onready var sprite: Sprite2D = $Sprite
@onready var area_2d: Area2D = $Area2D


func _process(delta: float) -> void:
	position += Vector2.from_angle(rotation - 1.57) * speed * delta
	
	if position.x < global_bounds.position.x - outside_margin or \
			position.x > global_bounds.position.x + global_bounds.size.x + outside_margin or \
			position.y < global_bounds.position.y - outside_margin or \
			position.y > global_bounds.position.y + global_bounds.size.y + outside_margin:
		queue_free()


func setup(json_file_name: String, bounds: Rect2i) -> void:
	var file := FileAccess.open(json_file_name, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	speed = json["speed"]
	damage = json["damage"]
	sprite.texture = load("res://assets/projectiles/%s" % json["filename"])
	global_bounds = bounds
	file.close()


func hit():
	queue_free()
