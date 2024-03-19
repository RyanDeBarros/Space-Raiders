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
	var basic_shot := Scenes.PROJECTILES["basic"].instantiate() as BasicShot
	basic_shot.projectile_image_dir = player.current_power_projectile.info["filename"]
	Info.projectile_manager.add_child(basic_shot)
	basic_shot.setup_from_node(player, player.projectile_info, "red.png", 1.57)
	basic_shot.add_to_group("player_owned")
