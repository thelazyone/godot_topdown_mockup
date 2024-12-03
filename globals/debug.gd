extends Node

var debug_enabled = false
var debug_console_enabled = false
var selected_debug_goon = null

var DEBUG_PERIOD = 1
var elapsed = 0

func console(text: String) -> void:
	print(text)
	
func select_goon(goon: Node):
	print("updating selected goon with ", goon)
	selected_debug_goon = goon

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed > DEBUG_PERIOD:
		elapsed = 0
		if selected_debug_goon and is_instance_valid(selected_debug_goon):
			print("Debug: goon is ", selected_debug_goon.global_position, ", target is ", typeof(selected_debug_goon.get_node("DecisionComponent").get_decision().target), " , at ", selected_debug_goon.get_node("DecisionComponent").get_decision().get_target_position())
