class_name Enemy
extends Node2D


var active := true:
	set(value):
		active = value
		for component in components.get_children():
			component.active = active

var health_component = null
var collide_component = null

@onready var area_2d: Area2D = $Area2D
@onready var components: Node = $Components
@onready var player: Player


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	for component in components.get_children():
		if component.name == "Health":
			health_component = component
		elif component.name == "Collide":
			collide_component = component


func _on_area_entered(area: Area2D):
	if area.is_in_group("area_player_projectile"):
		var proj := area.get_parent() as Projectile
		if health_component:
			health_component.receive_projectile(proj)
		else:
			proj.hit()
	elif area.is_in_group("area_player"):
		if collide_component:
			collide_component.player_enter()


func _on_area_exited(area: Area2D):
	if area.is_in_group("area_player"):
		if collide_component:
			collide_component.player_exit()


func die() -> void:
	queue_free()
