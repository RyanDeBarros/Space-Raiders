extends Node


const EXPLOSION_SCENE := preload("res://source/explosion/explosion.tscn")

var PROJECTILES = {
	"basic": preload("res://source/projectile/basic_shot.tscn"),
	"charge": preload("res://source/projectile/charge_shot.tscn"),
	"burst": preload("res://source/projectile/burst_shot.tscn"),
	#"bomb": preload("res://source/projectile/bomb_shot.tscn"),
	"cannon": preload("res://source/projectile/cannon_shot.tscn"),
	#"emp": preload("res://source/projectile/charge_shot.tscn"),
	#"laser": preload("res://source/projectile/charge_shot.tscn"),
}
