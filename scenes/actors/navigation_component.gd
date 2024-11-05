extends Node2D

var target = null
var local_target = null
var current_position = null
const POSITION_PRECISION = 20
const PATFHINDING_PERIOD_MS = 200

@onready var last_patfhinding_tick = Time.get_ticks_msec()
@onready var navigation_agent = $NavigationAgent2D

##############################
## INTERFACE
##############################
	
func set_target(input_position):
	if input_position:
		target = input_position
		navigation_agent.target_position = input_position
		##print("setting target to ", input_position)
		NavigationServer2D.agent_set_avoidance_enabled(navigation_agent, true)

	
func get_move(input_position = null):
	#if not target: return # TODO TBR?
	
	if input_position:
		set_target(input_position)
	
	# If no target, not moving
	if not local_target:
		return null
		

	return local_target

##############################
## LOOPS
##############################

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	
	# Updating the current bearing
	if target:
		
		# Updating the pathfinding only every X ms.
		# TODO - either use a timer or an int counter, if this proves to be 
		# too computationally intensive. 
		if Time.get_ticks_msec() - last_patfhinding_tick > PATFHINDING_PERIOD_MS:
			local_target = navigation_agent.get_next_path_position()
			last_patfhinding_tick = Time.get_ticks_msec()
		
		if get_parent().position.distance_to(target) < POSITION_PRECISION:
			local_target = null
