extends Node


func get_all_children(node: Node, arr := [] as Array[Node]) -> Array[Node]:
	var children := node.get_children()
	if not children.is_empty():
		for child in children:
			arr.push_back(child)
			arr += get_all_children(child)
	return arr


func propogate_mouse_filter(control: Control, mouse_filter: int) -> void:
	control.mouse_filter = mouse_filter
	for child in get_all_children(control):
		if child is Control:
			child.mouse_filter = mouse_filter
