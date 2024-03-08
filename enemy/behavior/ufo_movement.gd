extends BaseBehavior


var speed_dict: Dictionary
var speed: int
var direction: Vector2
var aggro_range_squared: float
var follow_spread: float
var move_interval_dict: Dictionary
var move_interval: float

var angular_speed := 1.0
var _speed := 0.0
var acceleration := 10.0
var deceleration := 10.0

@onready var move_interval_timer := $MoveIntervalTimer as Timer


func _ready() -> void:
	move_interval_timer.timeout.connect(_on_move_interval_end)
	setup()
	_on_move_interval_end()


func _process(delta: float) -> void:
	if active and enemy.position.distance_squared_to(player.position) <= aggro_range_squared:
		_speed = minf(_speed + acceleration, speed)
		if not direction:
			_on_move_interval_end()
	else:
		direction = Vector2.ZERO
		_speed = maxf(_speed - deceleration, 0)
	enemy.position += direction * delta * speed
	enemy.rotation += angular_speed * delta


func _on_move_interval_end() -> void:
	_restart_move_interval()
	if active:
		direction = enemy.position.direction_to(player.position).rotated(randf() * follow_spread)
	else:
		direction = Vector2.ZERO


func _restart_move_interval() -> void:
	speed = Math.rand_mediani(speed_dict["min"], speed_dict["median"], speed_dict["max"])
	move_interval = Math.rand_medianf(
			move_interval_dict["min"], move_interval_dict["median"], move_interval_dict["max"])
	move_interval_timer.start(move_interval)


func setup() -> void:
	var file := FileAccess.open(configuration, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	speed_dict = json["speed"]
	move_interval_dict = json["move_interval"]
	aggro_range_squared = json["aggro_range_squared"]
	follow_spread = json["follow_spread"]
	file.close()
