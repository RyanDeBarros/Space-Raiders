extends BaseBehavior


var range_squared_detect: int
var range_middle: int
var speed_mult: float
var orbiting_speed: float
var orbital_speed_pm: float

var range_velocity := Vector2.ZERO
var angular_velocity: float


func _ready() -> void:
	setup()
	angular_velocity = Math.pm_randf(orbiting_speed, orbital_speed_pm) * (randi_range(0, 1) * 2 - 1)


func _process(delta: float) -> void:
	var quadrance := enemy.position.distance_squared_to(player.position)
	if quadrance <= range_squared_detect:
		var direction := player.position.direction_to(enemy.position)
		range_velocity = direction * (range_middle - sqrt(quadrance)) * speed_mult
		var orbital_velocity := direction.rotated(1.57) * angular_velocity * delta
		enemy.position += range_velocity + orbital_velocity
		enemy.rotation = direction.angle() + 1.57


func setup():
	var file := FileAccess.open(configuration, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	range_squared_detect = json["range"]["detect"] ** 2
	range_middle = json["range"]["middle"]
	speed_mult = json["speed_mult"]
	orbiting_speed = json["orbiting_speed"]
	orbital_speed_pm = json["orbital_speed_pm"]
	file.close()
