class_name PlayerBurstShooter
extends Node


@export var player: Player


var shooting := false


func handle_clicked() -> void:
	if not shooting and player.power_meter > player.pps[Player.PowerProjectile.BURST]\
			["info"]["minimum_power"]:
		var info = player.pps[Player.PowerProjectile.BURST]["info"]
		player.power_meter -= info["minimum_power"]
		shooting = true
		for i in range(Math.rand_mediani(info["num"]["min"], info["num"]["med"],
				info["num"]["max"])):
			shoot_single()
			await get_tree().create_timer(info["await_time"]).timeout
		shooting = false
	else:
		AudioManager.play_sfx(AudioManager.SFXs.TWO_TONE)


func handle_released() -> void:
	pass # Nothing on release


func start_process() -> void:
	pass


func cancel_process() -> void:
	pass


func shoot_single() -> void:
	var power_proj = player.pps[Player.PowerProjectile.BURST]
	var burst_shot := power_proj["packed_scene"].instantiate() as BasicShot
	burst_shot.projectile_image_dir = power_proj["info"]["filename"]
	Info.projectile_manager.add_child(burst_shot)
	burst_shot.setup_from_node(player, power_proj["info"], "red.png")
	burst_shot.add_to_group(Groups.PLAYER_OWNED)
	AudioManager.play_sfx(AudioManager.SFXs.LASER_2)
