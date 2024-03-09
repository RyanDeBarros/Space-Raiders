extends BaseBehavior


var max_health: int
var health: int:
	set(value):
		health = maxi(value, 0)
		if health == 0:
			enemy.die()


func _ready() -> void:
	setup()
	health = max_health


func setup() -> void:
	var file := FileAccess.open(configuration, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	max_health = json["max_health"]
	file.close()


func take_damage(damage: int):
	health -= damage


func receive_projectile(projectile: Projectile):
	take_damage(projectile.damage)
	projectile.hit()
