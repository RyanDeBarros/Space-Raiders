class_name BaseBehavior


var enemy: Enemy
var tree: SceneTree
var player: Player
var active := true

var can_process := false
var can_take_damage := false
var can_collide_damage := false


func _init(enemy_: Enemy, scene_tree: SceneTree, _json_file_name: String = "") -> void:
	enemy = enemy_
	tree = scene_tree
	player = tree.get_first_node_in_group("player")
