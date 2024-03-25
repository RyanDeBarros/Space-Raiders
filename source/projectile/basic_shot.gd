class_name BasicShot
extends Area2D


@export var projectile_image_dir := "spaceMissiles_01/"
@export var hit_cloud_scale_mult := 1.0

@onready var projectile_motion: ProjectileMotion = $ProjectileMotion
@onready var sprite: Sprite2D = $Sprite

var damage: int


func _on_area_entered(area: Area2D) -> void:
	if is_in_group("player_owned"):
		if area.is_in_group("enemy"):
			area.projectile_hit(self)
			hit()
	elif is_in_group("enemy_owned"):
		if area is Player:
			area.projectile_hit(self)
			hit()


func setup_from_node(node: Node2D, projectile_info: Dictionary, colorpng: String, rotation_offset := 1.57):
	position = node.position
	projectile_motion.sync_velocity(\
			Vector2.from_angle(node.rotation + rotation_offset) * projectile_info["initial_speed"])
	projectile_motion.acceleration = projectile_info["acceleration"]
	damage = projectile_info["damage"]
	set_sprite_image(projectile_image_dir + colorpng)


func set_sprite_image(filename: String, asset_dir := "res://assets/projectiles"):
	sprite.texture = load("%s/%s" % [asset_dir, filename])


func hit():
	queue_free()
	var explosion = Scenes.HIT_CLOUD_SCENE.instantiate()
	get_tree().get_first_node_in_group("explosion_manager").add_child(explosion)
	explosion.position = position
	explosion.scale *= hit_cloud_scale_mult
