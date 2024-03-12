extends Node2D


@onready var player: Player = $Player
@onready var arena_collision: CollisionShape2D = $Arena/CollisionShape2D
@onready var projectile_manager: Node2D = $ProjectileManager
@onready var level_overlay: LevelOverlay = $Overlay/LevelOverlay


func _ready() -> void:
	Info.level_data["arena_rect"] = arena_collision.shape.get_rect()
	Info.player = player
	Info.projectile_manager = projectile_manager
	player.setup_camera_limits()
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)
	player.health_changed.connect(_on_player_health_changed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace"):
		get_tree().reload_current_scene()
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_player_health_changed(health: int) -> void:
	level_overlay.set_health_bar_proportion(float(health) / player.max_health)
