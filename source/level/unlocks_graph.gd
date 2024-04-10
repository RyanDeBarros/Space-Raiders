class_name UnlocksGraph
extends Node


class Unlock:
	var name: String
	var scene: PackedScene
	var type: String
	var req: String
	
	func _init(node: Dictionary) -> void:
		name = node["name"]
		scene = load(node["scene"])
		type = node["type"]
		req = node["req"] if node.has("req") else null
	
	func instance() -> BaseUnlock:
		var inst := scene.instantiate() as BaseUnlock
		inst.stage = Info.main_stage
		return inst

class U_recurring_add extends Unlock:
	var data: int
	
	func _init(node: Dictionary) -> void:
		super._init(node)
		data = node["increase"]
	
	func instance() -> BaseUnlock:
		var inst := super.instance()
		inst.data = data
		inst.find_child("Details").text %= str(data)
		return inst

class U_recurring_mul extends Unlock:
	var data: float
	
	func _init(node: Dictionary) -> void:
		super._init(node)
		data = node["factor"]
	
	func instance() -> BaseUnlock:
		var inst := super.instance()
		inst.data = data
		inst.find_child("Details").text = \
				inst.find_child("Details").text.format({"s": str(int(data * 100))})
		return inst

class U_prereq extends Unlock:
	var next: Dictionary
	
	func _init(node: Dictionary) -> void:
		super._init(node)
		next = UnlocksGraph._load_graph(node["next"])
	
	func instance() -> BaseUnlock:
		return super.instance()

class U_prereq_mmm extends Unlock:
	var next: Dictionary
	var data: Array
	
	func _init(node: Dictionary) -> void:
		super._init(node)
		next = UnlocksGraph._load_graph(node["next"])
		data = node["mmm"]
	
	func instance() -> BaseUnlock:
		var inst := super.instance()
		inst.data = data
		inst.find_child("Details2").text %= [str(data[0]), str(data[2])]
		return inst

class U_prereq_amount extends Unlock:
	var next: Dictionary
	var data: int
	
	func _init(node: Dictionary) -> void:
		super._init(node)
		next = UnlocksGraph._load_graph(node["next"])
		data = node["amount"]
	
	func instance() -> BaseUnlock:
		var inst := super.instance()
		inst.data = data
		inst.find_child("Details2").text %= str(data)
		return inst

class U_finite_amount extends Unlock:
	var data: Array
	var num: int
	var index := 0
	
	func _init(node: Dictionary) -> void:
		super._init(node)
		data = node["range_amount"]
		num = node["num"]
	
	func instance() -> BaseUnlock:
		var inst := super.instance()
		inst.data = data[index]
		inst.find_child("Details2").text %= str(data[index])
		return inst

class U_finite_add extends Unlock:
	var data: int
	var num: int
	var index := 0
	
	func _init(node: Dictionary) -> void:
		super._init(node)
		data = node["increase"]
		num = node["num"]
	
	func instance() -> BaseUnlock:
		var inst := super.instance()
		inst.data = data
		inst.find_child("Details2").text %= str(data)
		return inst

class U_finite_mmm extends Unlock:
	var data: Dictionary
	var num: int
	var index := 0
	
	func _init(node: Dictionary) -> void:
		super._init(node)
		data = node["range_mmm"]
		num = node["num"]
	
	func instance() -> BaseUnlock:
		var inst := super.instance()
		inst.data = [data["min"][index], data["med"][index], data["max"][index]]
		inst.find_child("Details2").text %= [str(data["min"][index]), str(data["max"][index])]
		return inst


var available_unlocks: Dictionary


func _ready() -> void:
	available_unlocks = UnlocksGraph._load_graph(Info.unlocks_graph)


static func _load_graph(graph: Array) -> Dictionary:
	var dict := {}
	for node in graph:
		var unlock: Unlock
		match node["type"]:
			"recurring_add":
				unlock = U_recurring_add.new(node)
			"recurring_mul":
				unlock = U_recurring_mul.new(node)
			"prereq":
				unlock = U_prereq.new(node)
			"prereq_mmm":
				unlock = U_prereq_mmm.new(node)
			"prereq_amount":
				unlock = U_prereq_amount.new(node)
			"finite_amount":
				unlock = U_finite_amount.new(node)
			"finite_add":
				unlock = U_finite_add.new(node)
			"finite_mmm":
				unlock = U_finite_mmm.new(node)
		dict[unlock.name] = unlock
	return dict


func poll_unlock(num := 3) -> Array[BaseUnlock]:
	var unlocks := available_unlocks.values().duplicate() as Array[Unlock]
	var instances = [] as Array[BaseUnlock]
	for unlock in unlocks:
		if unlock.req and not call(unlock.req):
			unlocks.erase(unlock)
	for i in range(num):
		var unlock := unlocks.pick_random() as Unlock
		unlocks.erase(unlock)
		instances.push_back(unlock.instance())
	return instances


func use(name_: String) -> void:
	var unlock := available_unlocks[name_] as Unlock
	match unlock.type:
		"prereq", "prereq_mmm", "prereq_amount":
			for key in unlock.next.keys():
				available_unlocks[key] = unlock.next[key]
			available_unlocks.erase(name_)
		"finite_amount", "finite_add", "finite_mmm":
			unlock.index += 1
			if unlock.index == unlock.num:
				available_unlocks.erase(name_)


func exists_power_projectile() -> bool:
	for pp in Info.player.pps:
		if pp["unlocked"]:
			return true
	return false
