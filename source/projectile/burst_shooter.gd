class_name BurstShooter
extends Node


@export var player: Player


var shooting := false


func handle_clicked() -> void:
	if not shooting and player.power_meter > player.current_power_projectile.minimum_power:
		player.power_meter -= player.current_power_projectile.minimum_power
		shooting = true
		var info = player.current_power_projectile.info
		for i in range(Math.rand_mediani(info["num"]["min"], info["num"]["med"],
				info["num"]["max"])):
			shoot_single()
			await get_tree().create_timer(info["await_time"]).timeout
		shooting = false


func handle_released() -> void:
	pass # Nothing on release


func start_process() -> void:
	pass


func cancel_process() -> void:
	pass


func shoot_single() -> void:
	var burst_shot := player.current_power_projectile.packed_scene.instantiate() as BasicShot
	burst_shot.projectile_image_dir = player.current_power_projectile.info["filename"]
	Info.projectile_manager.add_child(burst_shot)
	burst_shot.setup_from_node(player, player.current_power_projectile.info, "red.png", 1.57)
	burst_shot.add_to_group("player_owned")
