class_name Unlocker
extends Node


@onready var unlocks_graph := $UnlocksGraph as UnlocksGraph
@onready var stage := Info.main_stage
@onready var player := Info.player


#TODO
func call_unlock(name: String, data: Variant) -> void:
	match name:
		"UpgradeMaxHealth":
			var increase_health := player.health == player.max_health
			player.max_health += data
			player.health = player.max_health if increase_health else player.health
		"UpgradeHealingRate":
			pass
		"UpgradeHealingLength":
			pass
		"UpgradeDefense":
			pass
		"UpgradeShieldConsumption":
			pass
		"UpgradeShieldRegeneration":
			pass
		"UpgradeMaxPowerMeter":
			pass
		"UpgradePowerConsumption":
			pass
		"UpgradePowerRegeneration":
			pass
		"UpgradeDamage":
			pass
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
