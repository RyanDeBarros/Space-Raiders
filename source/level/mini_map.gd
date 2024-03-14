class_name MiniMap
extends Control


@export var sensor_weight_exponent := 0.5
@export var enemy_sensors_update_rate := 0.5

@onready var back: ColorRect = $Cutout/Back
@onready var player: TextureRect = $Cutout/Back/Player
@onready var nw: ColorRect = $BG/NW
@onready var bnw: ColorRect = $BG/BNW
@onready var n: ColorRect = $BG/N
@onready var bne: ColorRect = $BG/BNE
@onready var ne: ColorRect = $BG/NE
@onready var bwn: ColorRect = $BG/BWN
@onready var w: ColorRect = $BG/W
@onready var bws: ColorRect = $BG/BWS
@onready var ben: ColorRect = $BG/BEN
@onready var e: ColorRect = $BG/E
@onready var bes: ColorRect = $BG/BES
@onready var sw: ColorRect = $BG/SW
@onready var bsw: ColorRect = $BG/BSW
@onready var s: ColorRect = $BG/S
@onready var bse: ColorRect = $BG/BSE
@onready var se: ColorRect = $BG/SE



func _process(_delta: float) -> void:
	if visible:
		var arena_rect_inv := Info.level_data["arena_rect_inv"] as Rect2
		var rel_x := (Info.player.position.x - arena_rect_inv.position.x) * arena_rect_inv.size.x
		var rel_y := (Info.player.position.y - arena_rect_inv.position.y) * arena_rect_inv.size.y
		player.position.x = rel_x * back.size.x - 0.5 * player.size.x
		player.position.y = rel_y * back.size.y - 0.5 * player.size.y


func set_enemy_sensor_weights(nw_weight := 0.0, ne_weight := 0.0, sw_weight := 0.0,
		se_weight := 0.0, n_weight := 0.0, w_weight := 0.0, e_weight := 0.0,
		s_weight := 0.0) -> void:
	var tween := create_tween()
	
	tween.tween_property(nw, "modulate:a", nw_weight ** sensor_weight_exponent,
			enemy_sensors_update_rate)
	tween.parallel().tween_property(ne, "modulate:a", ne_weight ** sensor_weight_exponent,
			enemy_sensors_update_rate)
	tween.parallel().tween_property(sw, "modulate:a", sw_weight ** sensor_weight_exponent,
			enemy_sensors_update_rate)
	tween.parallel().tween_property(se, "modulate:a", se_weight ** sensor_weight_exponent,
			enemy_sensors_update_rate)
	tween.parallel().tween_property(n, "modulate:a", n_weight ** sensor_weight_exponent,
			enemy_sensors_update_rate)
	tween.parallel().tween_property(w, "modulate:a", w_weight ** sensor_weight_exponent,
			enemy_sensors_update_rate)
	tween.parallel().tween_property(e, "modulate:a", e_weight ** sensor_weight_exponent,
			enemy_sensors_update_rate)
	tween.parallel().tween_property(s, "modulate:a", s_weight ** sensor_weight_exponent,
			enemy_sensors_update_rate)
	
	
	tween.parallel().tween_property(bnw, "modulate:a", 0.5 * (nw_weight ** sensor_weight_exponent + n_weight ** sensor_weight_exponent),
			enemy_sensors_update_rate)
	tween.parallel().tween_property(bne, "modulate:a", 0.5 * (n_weight ** sensor_weight_exponent + ne_weight ** sensor_weight_exponent),
			enemy_sensors_update_rate)
	tween.parallel().tween_property(bwn, "modulate:a", 0.5 * (nw_weight ** sensor_weight_exponent + w_weight ** sensor_weight_exponent),
			enemy_sensors_update_rate)
	tween.parallel().tween_property(ben, "modulate:a", 0.5 * (ne_weight ** sensor_weight_exponent + e_weight ** sensor_weight_exponent),
			enemy_sensors_update_rate)
	tween.parallel().tween_property(bws, "modulate:a", 0.5 * (w_weight ** sensor_weight_exponent + sw_weight ** sensor_weight_exponent),
			enemy_sensors_update_rate)
	tween.parallel().tween_property(bes, "modulate:a", 0.5 * (e_weight ** sensor_weight_exponent + se_weight ** sensor_weight_exponent),
			enemy_sensors_update_rate)
	tween.parallel().tween_property(bsw, "modulate:a", 0.5 * (sw_weight ** sensor_weight_exponent + s_weight ** sensor_weight_exponent),
			enemy_sensors_update_rate)
	tween.parallel().tween_property(bse, "modulate:a", 0.5 * (s_weight ** sensor_weight_exponent + se_weight ** sensor_weight_exponent),
			enemy_sensors_update_rate)
