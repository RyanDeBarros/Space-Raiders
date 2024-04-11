class_name Unlocker
extends Node


var stage: Stage
var player: Player

@onready var unlocks_graph := $UnlocksGraph as UnlocksGraph


func _ready() -> void:
	call_deferred("_first_frame")


func _first_frame() -> void:
	stage = Info.main_stage
	player = Info.player


func call_unlock(name_: String, data: Variant) -> void:
	match name_:
		"UpgradeMaxHealth":
			var increase_health := player.health == player.max_health
			player.max_health += data
			player.health = player.max_health if increase_health else player.health
		"UpgradeHealingRate":
			player.healing_rate *= data
		"UpgradeHealingLength":
			player.healing_length *= data
		"UpgradeDefense":
			player.net_defense /= data
		"UpgradeShieldMinEnergy":
			player.shield_initiate_fraction *= data
		"UpgradeShieldConsumption":
			player.shield_consumption_rate *= data
		"UpgradeShieldRegeneration":
			player.shield_regeneration_rate *= data
		"UpgradeDamage":
			player.projectile_info["damage"] += data
		"UpgradeMaxPowerMeter":
			player.power_max_meter += data
			player.power_meter_changed.emit(player.power_meter)
		"UpgradePowerConsumption":
			player.power_meter_consumption_rate *= data
		"UpgradePowerRegeneration":
			player.power_meter_regeneration *= data
		"UnlockChargeShot":
			player.pps[Player.PowerProjectile.CHARGE]["unlocked"] = true
			player.current_power_projectile = Player.PowerProjectile.CHARGE
		"UpgradeChargeShotMinimumPower":
			player.pps[Player.PowerProjectile.CHARGE]["info"]["minimum_power"] *= data
		"UpgradeChargeShotMinDamage":
			player.pps[Player.PowerProjectile.CHARGE]["info"]["min_damage"] += data
		"UpgradeChargeShotDamageInc":
			player.pps[Player.PowerProjectile.CHARGE]["info"]["damage_inc"] += data
		"UpgradeChargeShotConsumeRate":
			player.pps[Player.PowerProjectile.CHARGE]["info"]["consume_rate"] *= data
		"UnlockBurstShot":
			player.pps[Player.PowerProjectile.BURST]["unlocked"] = true
			player.pps[Player.PowerProjectile.BURST]["num"] = {
				"min" = data[0],
				"med" = data[1],
				"max" = data[2]
			}
			player.current_power_projectile = Player.PowerProjectile.BURST
		"UpgradeBurstShotMinimumPower":
			player.pps[Player.PowerProjectile.BURST]["info"]["minimum_power"] *= data
		"UpgradeBurstShotDamage":
			player.pps[Player.PowerProjectile.BURST]["info"]["damage"] += data
		"UpgradeBurstShotNum":
			player.pps[Player.PowerProjectile.BURST]["num"] = {
				"min" = data[0],
				"med" = data[1],
				"max" = data[2]
			}
		"UnlockCannonShot":
			player.pps[Player.PowerProjectile.CANNON]["unlocked"] = true
			player.pps[Player.PowerProjectile.CANNON]["info"]["durability"] = data
			player.current_power_projectile = Player.PowerProjectile.CANNON
		"UpgradeCannonShotMinimumPower":
			player.pps[Player.PowerProjectile.CANNON]["info"]["minimum_power"] *= data
		"UpgradeCannonShotDamage":
			player.pps[Player.PowerProjectile.CANNON]["info"]["damage"] += data
		"UpgradeCannonShotDurability":
			player.pps[Player.PowerProjectile.CANNON]["info"]["durability"] = data
		"UpgradeCannonShotSpeed":
			player.pps[Player.PowerProjectile.CANNON]["info"]["initial_speed"] += data
		_:
			push_error("%s is not a valid unlock name" % name_)
