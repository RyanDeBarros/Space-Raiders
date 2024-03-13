extends Node


func get_all_children(node: Node, arr := [] as Array[Node]) -> Array[Node]:
	var children := node.get_children()
	if not children.is_empty():
		for child in children:
			arr.push_back(child)
			arr += get_all_children(child)
	return arr
