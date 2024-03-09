extends BaseBehavior


var cooldown: float
var cooldown_pm: float
var range_squared: float
var projectile_config: String

@onready var cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
	setup()
	cooldown_timer.timeout.connect(_on_cooldown_end)
	cooldown_timer.wait_time = Math.pm_randf(cooldown, cooldown_pm)


func _process(_delta: float) -> void:
	if enemy.position.distance_squared_to(player.position) <= range_squared:
		if cooldown_timer.is_stopped():
			cooldown_timer.start()
	else:
		cooldown_timer.stop()


func _on_cooldown_end():
	cooldown_timer.wait_time = Math.pm_randf(cooldown, cooldown_pm)
	shoot()


func shoot():
	var projectile := Scenes.PROJECTILE_SCENE.instantiate() as Projectile
	get_tree().get_first_node_in_group("projectile_manager").add_child(projectile)
	projectile.area_2d.add_to_group("area_enemy_projectile")
	projectile.setup(Scenes.ENEMY_PROJECTILE_CONFIG[projectile_config])
	projectile.position = enemy.position
	projectile.rotation = enemy.rotation + 3.14


func setup() -> void:
	var file := FileAccess.open(configuration, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	cooldown = json["cooldown"]
	cooldown_pm = json["cooldown_pm"]
	range_squared = json["range"] ** 2
	projectile_config = json["projectile_config"]
	file.close()
