extends BaseBehavior


@export_category("CollideComponent")
@export var health_component: Node

var collide_damage: int

var colliding_player: bool:
	set(value):
		colliding_player = value
		collide_player()

@onready var collide_damage_timer: Timer = $CollideDamageTimer


func _ready() -> void:
	setup()


func setup() -> void:
	var file := FileAccess.open(configuration, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	collide_damage = json["collide_damage"]
	file.close()


func collide_player() -> void:
	if colliding_player:
		if health_component:
			health_component.health -= player.collide_damage
		player.health -= collide_damage
		collide_damage_timer.start()


func player_enter() -> void:
	colliding_player = true


func player_exit() -> void:
	colliding_player = false
