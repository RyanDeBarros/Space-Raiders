class_name BaseBehavior
extends Node


@export var enemy: Enemy
@export_file("*.json") var configuration: String

var active := true

@onready var player := get_tree().get_first_node_in_group("player") as Player
