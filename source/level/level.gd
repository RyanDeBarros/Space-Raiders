extends Node2D


@onready var player: Player = $Player
@onready var arena_collision: CollisionShape2D = $Arena/CollisionShape2D
@onready var projectile_manager: Node2D = $ProjectileManager
@onready var level_overlay: LevelOverlay = $Overlay/LevelOverlay


func _ready() -> void:
	var arena_rect := arena_collision.shape.get_rect()
	Info.level_data["arena_rect"] = arena_rect
	Info.level_data["arena_rect_inv"] = Rect2(arena_rect.position.x, arena_rect.position.y,\
			1 / arena_rect.size.x, 1 / arena_rect.size.y)
	Info.player = player
	Info.projectile_manager = projectile_manager
	
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)
	player.setup_camera_limits()
	
	player.health_changed.connect(_on_player_health_changed)
	player.shield_meter_changed.connect(_on_player_shield_meter_changed)
	level_overlay.set_shield_bar_minimum(player.shield_initiate_fraction)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace"):
		get_tree().reload_current_scene()
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event.is_action_pressed("full_screen"):
		var fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN\
				if not fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	if event.is_action_pressed("toggle_minimap"):
		level_overlay.toggle_minimap()


func _on_player_health_changed(health: int) -> void:
	level_overlay.set_health_bar_proportion(float(health) / player.max_health)


func _on_player_shield_meter_changed(shield_meter: float) -> void:
	level_overlay.set_shield_bar_proportion(shield_meter)
