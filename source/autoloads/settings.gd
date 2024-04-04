extends Node


var player_camera_smoothing := 0.01:
	set(value):
		player_camera_smoothing = value
		var player := get_tree().get_first_node_in_group(Groups.PLAYER) as Player
		if player:
			player.update_camera_smoothing()
