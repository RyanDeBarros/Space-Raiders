class_name EnemySpawnOption
extends Node


@export var type_index := -1
@export var weight_distribution: Curve
@export_group("Difficulty", "difficulty_")
@export var difficulty_lower_distribution: Curve
@export var difficulty_peak_distribution: Curve
@export var difficulty_upper_distribution: Curve
