class_name CannonShot
extends Area2D


@export var projectile_image_dir := "spaceMissiles_01/"
@export var durability := 3
@export var const_hit_delay := 0.5
@export var hit_cloud_scale_mult := 1.0

@onready var projectile_motion: ProjectileMotion = $ProjectileMotion
@onready var sprite: Sprite2D = $Sprite

var damage: int
var hit_dict := {}


func _process(delta: float) -> void:
	for target in hit_dict.keys():
		hit_dict[target] -= delta
		if hit_dict[target] <= 0:
			target.projectile_hit(self)
			hit()
			hit_dict[target] = const_hit_delay


func _on_area_entered(area: Area2D) -> void:
	if is_in_group(Groups.PLAYER_OWNED):
		if area.is_in_group(Groups.ENEMY):
			area.projectile_hit(self)
			hit()
			hit_dict[area] = const_hit_delay
	elif is_in_group(Groups.ENEMY_OWNED):
		if area is Player:
			area.projectile_hit(self)
			hit()
			hit_dict[area] = const_hit_delay
	if area.is_in_group(Groups.ASTEROID):
		hit()


func _on_area_exited(area: Area2D) -> void:
	if is_in_group(Groups.PLAYER_OWNED):
		if area.is_in_group(Groups.ENEMY):
			hit_dict.erase(area)
	elif is_in_group(Groups.ENEMY_OWNED):
		if area is Player:
			hit_dict.erase(area)


func setup_from_node(node: Node2D, projectile_info: Dictionary, colorpng: String, rotation_offset := 1.57):
	position = node.position
	projectile_motion.sync_velocity(\
			Vector2.from_angle(node.rotation + rotation_offset) * projectile_info["initial_speed"])
	projectile_motion.acceleration = projectile_info["acceleration"]
	damage = projectile_info["damage"]
	durability = projectile_info["durability"]
	set_sprite_image(projectile_image_dir + colorpng)


func set_sprite_image(filename: String, asset_dir := "res://assets/projectiles"):
	sprite.texture = load("%s/%s" % [asset_dir, filename])


func hit():
	durability -= 1
	if durability <= 0:
		queue_free()
	var explosion = Scenes.HIT_CLOUD.instantiate()
	get_tree().get_first_node_in_group(Groups.EXPLOSION_MANAGER).add_child(explosion)
	explosion.position = position
	explosion.scale *= hit_cloud_scale_mult
