extends Node


const TITLE_SCREEN := preload("res://source/ui/title_screen.tscn")
const SANDBOX := preload("res://source/level/sandbox.tscn")
const EXPLOSION := preload("res://source/explosion/explosion.tscn")
const HIT_CLOUD := preload("res://source/explosion/hit_cloud.tscn")

var PROJECTILES = {
	"basic": preload("res://source/projectile/basic_shot.tscn"),
	"charge": preload("res://source/projectile/charge_shot.tscn"),
	"burst": preload("res://source/projectile/basic_shot.tscn"),
	#"bomb": preload("res://source/projectile/bomb_shot.tscn"),
	"cannon": preload("res://source/projectile/cannon_shot.tscn"),
	#"emp": preload("res://source/projectile/charge_shot.tscn"),
	#"laser": preload("res://source/projectile/charge_shot.tscn"),
}
