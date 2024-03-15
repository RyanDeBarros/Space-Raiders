extends Node


const EXPLOSION_SCENE := preload("res://source/explosion/explosion.tscn")

const PROJECTILES = {
	"basic": preload("res://source/projectile/basic_shot.tscn"),
	"charge": preload("res://source/projectile/charge_shot.tscn"),
	"burst": preload("res://source/projectile/charge_shot.tscn"),
	"bomb": preload("res://source/projectile/charge_shot.tscn"),
	"cannon": preload("res://source/projectile/charge_shot.tscn"),
	"emp": preload("res://source/projectile/charge_shot.tscn"),
	"laser": preload("res://source/projectile/charge_shot.tscn"),
}

var SHOOTERS = {
	"charge_shot" = ChargeShooter,
	"burst_shot" = ChargeShooter,
	"bomb_shot" = ChargeShooter,
	"cannon_shot" = ChargeShooter,
	"emp_shot" = ChargeShooter,
	"laser_shot" = ChargeShooter,
}
