class_name PrismaticPerseveranceEffect

const ALL_ELEMENTS = ["Norm", "Fire", "Water", "Wind", "Astra", "Umbra", "Arcane", "Exia", "Crux", "Tera", "Neos", "Luxem"]

static func apply_activation(elements_node: Node, is_opponent: bool = false):
	if not elements_node:
		return
	var prefix = "Opponent" if is_opponent else ""
	for element_name in ALL_ELEMENTS:
		var element_node = elements_node.get_node_or_null(prefix + element_name)
		if element_node and element_node.has_method("activate"):
			element_node.activate()

static func apply_deactivation(elements_node: Node, is_opponent: bool = false):
	if not elements_node:
		return
	var prefix = "Opponent" if is_opponent else ""
	for element_name in ALL_ELEMENTS:
		var element_node = elements_node.get_node_or_null(prefix + element_name)
		if element_node and element_node.has_method("deactivate"):
			element_node.deactivate()
