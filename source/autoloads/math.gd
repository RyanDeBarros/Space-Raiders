extends Node


# RNG

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


func rand_mediani_dict(dict: Dictionary) -> int:
	return rand_mediani(dict["min"], dict["median"], dict["max"])


func rand_medianf_dict(dict: Dictionary) -> float:
	return rand_medianf(dict["min"], dict["median"], dict["max"])


func pm_randf(center: float, pm: float) -> float:
	return randf_range(center - pm, center + pm)
