extends Node


func rand_mediani(min_: int, median_: int, max_: int) -> int:
	if randf() < 0.5:
		return randi_range(min_, median_)
	else:
		return randi_range(median_, max_)


func rand_medianf(min_: float, median_: float, max_: float) -> float:
	if randf() < 0.5:
		return randf_range(min_, median_)
	else:
		return randf_range(median_, max_)


func pm_randf(center: float, pm: float) -> float:
	return randf_range(center - pm, center + pm)
