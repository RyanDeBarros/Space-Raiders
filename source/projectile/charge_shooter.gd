class_name ChargeShooter
extends Node


@export var player: Player


var active := false
var to_shoot := false
var build_up := false
var build_up_damage := 0.0


func _process(delta: float) -> void:
	if active:
		if build_up:
			player.descrease_power_meter(delta)
			if player.power_meter == 0.0:
				build_up = false
			build_up_damage += player.current_power_projectile.info["damage_inc"] * delta


func handle_clicked() -> void:
	if player.power_meter > player.current_power_projectile.minimum_power:
		player.power_meter -= player.current_power_projectile.minimum_power
		player.is_power_meter_consuming = true
		to_shoot = true
		build_up = true
		build_up_damage = player.current_power_projectile.info["min_damage"]


func handle_released() -> void:
	if to_shoot:
		to_shoot = false
		player.is_power_meter_consuming = false
		var charge_shot := player.current_power_projectile.packed_scene.instantiate() as ChargeShot
		Info.projectile_manager.add_child(charge_shot)
		charge_shot.setup_from_node(player, player.current_power_projectile.info,
				"red.png", int(build_up_damage))
		charge_shot.add_to_group("player_owned")
		build_up = false
		build_up_damage = 0.0


func start_process() -> void:
	active = true


func cancel_process() -> void:
	active = false
	to_shoot = false
	build_up = false
	build_up_damage = 0.0
	player.is_power_meter_consuming = false
