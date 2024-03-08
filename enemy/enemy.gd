class_name Enemy
extends Node2D


@export var behavior_script: GDScript
@export_file("*.json") var behavior_json: String

var behavior

var colliding_player: bool:
	set(value):
		colliding_player = value
		collide_player()

@onready var area_2d: Area2D = $Area2D
@onready var collide_damage_timer: Timer = $CollideDamageTimer
@onready var player: Player

func _ready() -> void:
	behavior = behavior_script.new(self, get_tree(), behavior_json)
	player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	behavior._process(delta)


func _on_area_entered(area: Area2D):
	if area.is_in_group("area_player_projectile"):
		var proj := area.get_parent() as Projectile
		behavior.take_damage(proj.damage)
		proj.hit()
	elif area.is_in_group("area_player"):
		colliding_player = true


func _on_area_exited(area: Area2D):
	if area.is_in_group("area_player"):
		colliding_player = false


func collide_player() -> void:
	if colliding_player:
		behavior.take_damage(player.collide_damage)
		player.health -= behavior.collide_damage
		collide_damage_timer.start()


func die() -> void:
	queue_free()
