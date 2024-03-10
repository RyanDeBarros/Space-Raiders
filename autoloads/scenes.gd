extends Node


const EXPLOSION_SCENE := preload("res://explosion/explosion.tscn")

const PLAYER_PROJECTILE_CONFIG = {
	"basic": "res://txt/projectile_info/basic.json"
}

const ENEMY_PROJECTILE_CONFIG = {
	"basic": "res://txt/projectile_info/basic_slow.json"
}


const PROJECTILES = {
	"basic": preload("res://projectile/basic_shot.tscn")
}
