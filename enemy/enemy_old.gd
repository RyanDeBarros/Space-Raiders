class_name EnemyOld
extends Node2D


@export var explosion_scale_mult := 1.0

var active := true:
	set(value):
		active = value
		for component in components.get_children():
			component.active = active

var health_component = null
var collide_component = null

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
	if area is Player:
		if collide_component:
			collide_component.player_enter()


func _on_area_exited(area: Area2D):
	if area is Player:
		if collide_component:
			collide_component.player_exit()


func projectile_hit(projectile):
	if health_component:
		health_component.receive_projectile(projectile)


func die() -> void:
	var explosion = Scenes.EXPLOSION_SCENE.instantiate()
	get_tree().get_first_node_in_group("explosion_manager").add_child(explosion)
	explosion.position = position
	explosion.scale *= explosion_scale_mult
	queue_free()
