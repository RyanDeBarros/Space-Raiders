extends Node


# Geometry

## Signed difference between two radian angles each on [0, 2 * PI], in the interval [-pi, pi]
func angle_diff(from: float, to: float) -> float:
	var zero_to_2pi := to - from
	return zero_to_2pi if zero_to_2pi < PI else zero_to_2pi - 2 * PI


# RNG

func rand_mediani(min_: int, median_: int, max_: int) -> int:
	var r = randf()
	if r < 0.5:
		return roundi(2 * (median_ - min_) * r + min_)
	else:
		return roundi(2 * (max_ - median_) * r + 2 * median_ - max_)


func rand_medianf(min_: float, median_: float, max_: float) -> float:
	var r = randf()
	if r < 0.5:
		return 2 * (median_ - min_) * r + min_
	else:
		return 2 * (max_ - median_) * r + 2 * median_ - max_


func rand_mediani_dict(dict: Dictionary) -> int:
	return rand_mediani(dict["min"], dict["median"], dict["max"])


func rand_medianf_dict(dict: Dictionary) -> float:
	return rand_medianf(dict["min"], dict["median"], dict["max"])


func pm_randf(center: float, pm: float) -> float:
	return randf_range(center - pm, center + pm)


func select(list: Array[Variant], weight_fn) -> Variant:
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
