class_name MiniMap
extends Control


@onready var back: ColorRect = $Cutout/Back
@onready var player: TextureRect = $Cutout/Back/Player


func _process(delta: float) -> void:
	if visible:
		var arena_rect_inv := Info.level_data["arena_rect_inv"] as Rect2
		var rel_x := (Info.player.position.x - arena_rect_inv.position.x) * arena_rect_inv.size.x
		var rel_y := (Info.player.position.y - arena_rect_inv.position.y) * arena_rect_inv.size.y
		player.position.x = player.scale.x * (rel_x * back.size.x - 0.5 * player.size.x)
		player.position.y = player.scale.y * (rel_y * back.size.y - 0.5 * player.size.y)
