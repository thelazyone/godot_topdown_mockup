extends Node2D

# Decision Component relies on the current types of groups to exist:
# - "goons" -> all kinds of units
# - "checkpoints" -> targets that you might want to reach and control
# - "cover" -> all cover elements

# Parameters
@export var NOTICE_SPEED = 1 # How fast alert grows
@export var SPOT_RANGE_CLOSE = 200 # while in green-yellow alert
@export var SPOT_RANGE_LONG = 500 # while in red alert.

# Internal Alert System
var alert_level : float = 0
const yellow_threshold : float = 1
const red_threshold : float = 2

var is_in_cover : bool = false
var is_shooting : bool = false

# Local decision variables
var current_target_enemy = null

# Other components' handles
var navigation_component = Resource # TODO probably useless-TBR

##############################
## PUBLIC METHODS
##############################

func get_decision() -> Decision:
	var out_decision = Decision.new()
	
	# If low alert, a simple movement would do.
	if alert_level < 1:
		
		# Search for the next checkpoint.
		var all_checkpoints = get_tree().get_nodes_in_group("checkpoints")
		if all_checkpoints: 
		
			# Checking for each checkpoint if it's reachable, and finding the closer to reach. 
			var min_distance = 999999
			var chosen_checkpoint = null
			for checkpoint in all_checkpoints:
				if _range_to(checkpoint) < min_distance:
					min_distance = _range_to(checkpoint)
					chosen_checkpoint = checkpoint
			
			if chosen_checkpoint != null:
				out_decision.type = Decision.Types.MOVE
				out_decision.target = chosen_checkpoint
				out_decision.weight = 1 # TODO this should be evaluated properly.
				
				## Returning decision MOVE
				return out_decision

	# If medium alert, there's movement towards things that are suspicious.
	if alert_level < 2:
		var selected_target = _get_best_target(_get_spot_range())
		if selected_target != null:
			out_decision.type = Decision.Types.PURSUE
			out_decision.target = selected_target
			out_decision.weight = 1 # TODO this should be evaluated properly.
			
			## Returning decision PURSUE
			return out_decision
	
	# Case Attack
	if alert_level > 2:
		var selected_target = _get_best_target(min(get_parent().WEAPON_RANGE, _get_spot_range()))
		if selected_target:
			out_decision.type = Decision.Types.ATTACK
			out_decision.target = selected_target
			out_decision.weight = 1 # TODO this should be calculated!
			
			## Returning decision ATTACK
			return out_decision 
	
	# TODO COVER!!!
	
	## Returning decision IDLE
	return out_decision

##############################
## LOOPS
##############################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# TODO this could be done more rarely, for optimization
	# Checking whether to increase or decrease the attention.
	var nearby_threats = _get_targets(_get_spot_range()).size()
	if nearby_threats == 0:
		alert_level -= delta * NOTICE_SPEED
	else:
		alert_level += delta * NOTICE_SPEED * sqrt(float(nearby_threats))

##############################
## PRIVATE METHODS
##############################

func _get_best_target(range : float, faction : int = 0) -> Node:
	var all_targets = _get_targets(range, faction)
	
	# TODO IMPROVE pick the closest for now, there could be more decision-making
	var best_target = null
	
	# sticking with the current target for a while even if there's a closer one
	var closest_range : float = 99999
	if current_target_enemy and is_instance_valid(current_target_enemy):
		if _check_line_of_sight(current_target_enemy):
			closest_range = _range_to(current_target_enemy) * .9
			best_target = current_target_enemy

	# Searching among others for one that is closer.
	for target in all_targets:
		var target_distance = _range_to(target)
		if target_distance < range:
			closest_range = target_distance
			best_target = target
	return best_target

# Returns the range of spotting considering the current alert level of the goon.
func _get_spot_range():
	
	# TODO IMPROVE: for now making is discrete. Maybe a step function would be nice.
	if alert_level < 2:
		return SPOT_RANGE_CLOSE
	return SPOT_RANGE_LONG

# looks for targets within range and LOS. Optionally, selecting only one faction (if != 0)
func _get_targets(range : float, faction : int = 0) -> Array:
	var targets = []
	for goon in get_tree().get_nodes_in_group("goons"):
		var distance = _range_to(goon)
		if distance >= range: 
			continue
		if faction != 0 and goon.FACTION != faction:
			continue
		if faction == 0 and goon.FACTION == get_parent().FACTION:
			continue
		
		if _check_line_of_sight(goon):
			targets.append(goon)
			
	return targets

# Searches for covers that provide cover to all enemies. If a cover is exposed, it's ignored.
func _get_covers(range : float) -> Array:
	var covers = []
	
	# TODO IMPROVE for now it just lists covers within range.
	for cover in get_tree().get_nodes_in_group("cover"):
		var distance = _range_to(cover)
		if distance >= range: 
			continue
		
		if _check_line_of_sight(cover):
			covers.append(cover)
	
	return covers

func _check_line_of_sight(target_object : Node) -> bool:
	
	if target_object and is_instance_valid(target_object):
		# Using this: https://www.reddit.com/r/godot/comments/duy05l/npc_line_of_sight_godot_2d_tutorial_the_combat/
		var space_state = get_world_2d().direct_space_state
		var raycast_query = PhysicsRayQueryParameters2D.create(get_parent().position, target_object.position, get_parent().collision_mask, [self, target_object])
		var raycast_result = space_state.intersect_ray(raycast_query)
		if raycast_result.is_empty():
			return true
	return false

func _range_to(target : Node) -> float:
	return get_parent().global_position.distance_to(target.global_position)
	
