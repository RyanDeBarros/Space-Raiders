extends Node


func rand_mediani(min: int, median: int, max: int) -> int:
	if randf() < 0.5:
		return randi_range(min, median)
	else:
		return randi_range(median, max)


func rand_medianf(min: float, median: float, max: float) -> float:
	if randf() < 0.5:
		return randf_range(min, median)
	else:
		return randf_range(median, max)
