class_name CannonShooter
extends Node


@export var player: Player


func handle_clicked() -> void:
	var power_proj = player.pps[Player.PowerProjectile.CANNON]["info"]
	if player.power_meter > power_proj["minimum_power"]:
		player.power_meter -= power_proj["minimum_power"]
		
		var cannon_shot := player.pps[Player.PowerProjectile.CANNON]["packed_scene"].instantiate()\
				as CannonShot
		cannon_shot.projectile_image_dir = power_proj["filename"]
		Info.projectile_manager.add_child(cannon_shot)
		cannon_shot.setup_from_node(player, power_proj, "red.png", 1.57)
		cannon_shot.add_to_group(Groups.PLAYER_OWNED)
		AudioManager.play_sfx(AudioManager.SFX.laser_2)
	else:
		AudioManager.play_sfx(AudioManager.SFX.two_tone)


func handle_released() -> void:
	pass # Nothing on release


func start_process() -> void:
	pass


func cancel_process() -> void:
	pass
