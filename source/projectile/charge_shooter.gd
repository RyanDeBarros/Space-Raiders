class_name ChargeShooter
extends Node


@export var player: Player
@export var charge_up_vol_db := -5.0


var to_shoot := false
var build_up := false
var build_up_damage := 0.0
var audio_id := -1


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if build_up:
		var info = player.pps[Player.PowerProjectile.CHARGE]["info"]
		player.descrease_power_meter(delta * info["consume_rate"])
		if player.power_meter == 0.0:
			build_up = false
		build_up_damage += info["damage_inc"] * delta


func handle_clicked() -> void:
	var power_proj = player.pps[Player.PowerProjectile.CHARGE]["info"]
	if player.power_meter > power_proj["minimum_power"]:
		player.power_meter -= power_proj["minimum_power"]
		player.is_power_meter_consuming = true
		to_shoot = true
		build_up = true
		build_up_damage = power_proj["min_damage"]
		audio_id = AudioManager.begin_stream(AudioManager.SFX_stream.charge_up,\
				false, Vector2.ZERO, charge_up_vol_db)
	else:
		AudioManager.play_sfx(AudioManager.SFX.two_tone)


func handle_released() -> void:
	if to_shoot:
		to_shoot = false
		player.is_power_meter_consuming = false
		var power_proj = player.pps[Player.PowerProjectile.CHARGE]
		var charge_shot := power_proj["packed_scene"].instantiate() as ChargeShot
		Info.projectile_manager.add_child(charge_shot)
		charge_shot.setup_from_node(player, power_proj["info"],
				"red.png", roundi(build_up_damage))
		charge_shot.add_to_group(Groups.PLAYER_OWNED)
		AudioManager.play_sfx(AudioManager.SFX.laser_2)
		build_up = false
		build_up_damage = 0.0
		AudioManager.cancel_stream(audio_id)


func start_process() -> void:
	set_process(true)


func cancel_process() -> void:
	set_process(false)
	to_shoot = false
	build_up = false
	build_up_damage = 0.0
	AudioManager.cancel_stream(audio_id)
	player.is_power_meter_consuming = false
