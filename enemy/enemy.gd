class_name Enemy
extends Node2D


@export var behavior_script: GDScript
@export_file("*.json") var behavior_json: String

@export_group("Combat")
@export var max_health := 100
@export var collide_damage := 50

var behavior

var health: int:
	set(value):
		health = maxi(value, 0)
		if health == 0:
			die()

@onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	behavior = behavior_script.new(self, get_tree(), behavior_json)
	health = max_health
	area_2d.area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	behavior._process(delta)


func _on_area_entered(area: Area2D):
	if area.is_in_group("area_player_projectile"):
		var proj := area.get_parent() as Projectile
		health -= proj.damage
		proj.hit()
	elif area.is_in_group("area_player"):
		var player := area.get_parent() as Player
		health -= player.collide_damage
		player.health -= collide_damage


func die() -> void:
	queue_free()
