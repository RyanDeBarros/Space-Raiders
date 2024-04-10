class_name Unlocker
extends Node


@onready var unlocks_graph := $UnlocksGraph as UnlocksGraph
@onready var stage := Info.main_stage
@onready var player := Info.player


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
		"UpgradeShieldConsumption":
			player.shield_consumption_rate *= data
		"UpgradeShieldRegeneration":
			player.shield_regeneration_rate *= data
		"UpgradeDamage":
			player.projectile_damage += data
		"UpgradeMaxPowerMeter":
			player.power_max_meter += data
			player.power_meter_changed.emit(player.power_meter)
		"UpgradePowerConsumption":
			player.power_meter_consumption_rate *= data
		"UpgradePowerRegeneration":
			player.power_meter_regeneration *= data
		"UnlockChargeShot":
			pass
		"UpgradeChargeShotMinimumPower":
			pass
		"UpgradeChargeShotDamageInc":
			pass
		"UpgradeChargeShotConsumeRate":
			pass
		"UnlockBurstShot":
			pass
		"UpgradeBurstShotMinimumPower":
			pass
		"UpgradeBurstShotDamage":
			pass
		"UpgradeBurstShotNum":
			pass
		"UnlockCannonShot":
			pass
		"UpgradeCannonShotMinimumPower":
			pass
		"UpgradeCannonShotDamage":
			pass
		"UpgradeCannonShotDurability":
			pass
		"UpgradeCannonShotSpeed":
			pass
