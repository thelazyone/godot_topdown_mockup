extends Node2D

const POSITION_PRECISION = 20

var nav_latest_tick = 0
const PERIOD_MS = 200

@onready var navigation_agent = $NavigationAgent2D

##############################
## INTERFACE
##############################
	
# Allows to set target separately from the get_move call.
func set_target(input_position):
	if input_position:
		navigation_agent.target_position = input_position

# Returns null if there is no target or there is no path to it.
func get_move(input_position = null):
	if input_position:
		set_target(input_position)
	var next_step = _calculate_path()
	return _calculate_path()

##############################
## LOOPS
##############################

func _ready() -> void:
	NavigationServer2D.agent_set_avoidance_enabled(navigation_agent.get_rid(), true)

func _process(delta: float) -> void:
	pass

func _calculate_path():
	if not navigation_agent.target_position:
		return null
	if get_parent().position.distance_to(navigation_agent.target_position) < POSITION_PRECISION:
		return null
	return navigation_agent.get_next_path_position()
	
