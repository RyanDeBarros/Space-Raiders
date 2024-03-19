class_name CannonShooter
extends Node


@export var player: Player


func handle_clicked() -> void:
	if player.power_meter > player.current_power_projectile.minimum_power:
		player.power_meter -= player.current_power_projectile.minimum_power
		
		var cannon_shot := player.current_power_projectile.packed_scene.instantiate() as CannonShot
		cannon_shot.projectile_image_dir = player.current_power_projectile.info["filename"]
		Info.projectile_manager.add_child(cannon_shot)
		cannon_shot.setup_from_node(player, player.current_power_projectile.info, "red.png", 1.57)
		cannon_shot.add_to_group("player_owned")


func handle_released() -> void:
	pass # Nothing on release


func start_process() -> void:
	pass


func cancel_process() -> void:
	pass
