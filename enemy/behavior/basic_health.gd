extends BaseBehavior


var max_health: int
var health: int:
	set(value):
		health = maxi(value, 0)
		if health == 0:
			enemy.queue_free()


func _init(enemy_: Enemy, scene_tree: SceneTree, json_file_name: String) -> void:
	super._init(enemy_, scene_tree)
	can_take_damage = true
	setup(json_file_name)
	health = max_health


func setup(json_file_name: String) -> void:
	var file := FileAccess.open(json_file_name, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	max_health = json["max_health"]
	file.close()


func take_damage(damage: int):
	health -= damage
