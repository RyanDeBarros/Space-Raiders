extends BaseBehavior


@export var projectile_info_index := "basic_slow"

var cooldown: float
var cooldown_pm: float
var range_squared: float
var projectile_config: String
var projectile_info: Dictionary

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var projectile_manager := get_tree().get_first_node_in_group("projectile_manager")


func _ready() -> void:
	setup()
	cooldown_timer.timeout.connect(_on_cooldown_end)
	cooldown_timer.wait_time = Math.pm_randf(cooldown, cooldown_pm)
	projectile_info = Info.projectile_JSON[projectile_info_index]


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
	var basic_shot := Scenes.PROJECTILES["basic"].instantiate() as BasicShot
	projectile_manager.add_child(basic_shot)
	basic_shot.setup_from_node(enemy, projectile_info, 1.57)
	basic_shot.add_to_group("enemy_owned")


func setup() -> void:
	var file := FileAccess.open(configuration, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	cooldown = json["cooldown"]
	cooldown_pm = json["cooldown_pm"]
	range_squared = json["range"] ** 2
	projectile_config = json["projectile_config"]
	file.close()
