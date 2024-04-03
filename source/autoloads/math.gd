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


func select(list: Array[Variant], caller, weight_fn) -> Variant:
	var total_weight := 0.0
	var weights = []
	for v in list:
		var weight = weight_fn.call(v)
		weights.push_back(weight)
		total_weight += weight
	var r := total_weight * randf()
	var i = 0
	while r > weights[i]:
		r -= weights[i]
		i += 1
	return list[i]
