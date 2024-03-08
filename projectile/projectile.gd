class_name Projectile
extends Node2D


var global_bounds: Rect2
var outside_margin := 100.0

var speed := 500.0


func _process(delta: float) -> void:
	position += Vector2.from_angle(rotation - 1.57) * speed * delta
	
	if position.x < global_bounds.position.x - outside_margin or \
			position.x > global_bounds.position.x + global_bounds.size.x + outside_margin or \
			position.y < global_bounds.position.y - outside_margin or \
			position.y > global_bounds.position.y + global_bounds.size.y + outside_margin:
		queue_free()
