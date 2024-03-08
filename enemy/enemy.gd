class_name Enemy
extends Node2D


class EnemyBehavior extends Resource:
	var scripts := [] as Array[GDScript]
	var configs := [] as Array[String]
	var objs: Array[BaseBehavior]
	
	var active := true:
		set(value):
			active = value
			for obj in objs:
				obj.active = active
	
	func setup(enemy: Enemy, tree: SceneTree) -> void:
		for i in range(scripts.size()):
			if scripts[i] and configs[i]:
				objs.push_back(scripts[i].new(enemy, tree, configs[i]))
	
	func _process(delta: float) -> void:
		for obj in objs:
			if obj.can_process:
				obj._process(delta)
	
	func take_damage(damage: int) -> void:
		for obj in objs:
			if obj.can_take_damage:
				obj.take_damage(damage)
	
	func collide_damage() -> int:
		var damage := 0
		for obj in objs:
			if obj.can_collide_damage:
				damage += obj.collide_damage
		return damage


@export_group("Behavior")

@export_subgroup("Components", "bs_")
@export var bs_health: GDScript
@export var bs_collide: GDScript
@export var bs_movement: GDScript

@export_subgroup("Configurations", "bj_")
@export_file("*.json") var bj_health: String
@export_file("*.json") var bj_collide: String
@export_file("*.json") var bj_movement: String


var behavior: EnemyBehavior

var colliding_player: bool:
	set(value):
		colliding_player = value
		collide_player()

var active := true:
	set(value):
		active = value
		behavior.active = value

@onready var area_2d: Area2D = $Area2D
@onready var collide_damage_timer: Timer = $CollideDamageTimer
@onready var player: Player

func _ready() -> void:
	behavior = EnemyBehavior.new()
	behavior.scripts += [bs_health, bs_collide, bs_movement]
	behavior.configs += [bj_health, bj_collide, bj_movement]
	behavior.setup(self, get_tree())
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
		player.health -= behavior.collide_damage()
		collide_damage_timer.start()


func die() -> void:
	queue_free()
