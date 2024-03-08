extends BaseBehavior


var collide_damage: int


func _init(enemy_: Enemy, scene_tree: SceneTree, json_file_name: String) -> void:
	super._init(enemy_, scene_tree)
	can_collide_damage = true
	setup(json_file_name)


func setup(json_file_name: String) -> void:
	var file := FileAccess.open(json_file_name, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	collide_damage = json["collide_damage"]
	file.close()
