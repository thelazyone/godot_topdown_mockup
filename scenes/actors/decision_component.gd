extends Node2D

# Parameters
@export var NOTICE_SPEED = 1 # How fast alert grows
@export var SPOT_RANGE_CLOSE = 200 # while in green-yellow alert
@export var SPOT_RANGE_LONG = 500 # while in red alert.

# Alert System
var alert_level : float = 0
const yellow_threshold : float = 1
const red_threshold : float = 2

# Local decision variables
var current_target_enemy = null

##############################
## PUBLIC METHODS
##############################

func get_best_target(range : float, faction : int = 0) -> Node:
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


##############################
## LOOPS
##############################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Checking whether to increase or decrease the attention.
	var nearby_threats = _get_targets(_get_spot_range()).size()
	if nearby_threats == 0:
		alert_level -= delta * NOTICE_SPEED
	else:
		alert_level += delta * NOTICE_SPEED * sqrt(float(nearby_threats))

##############################
## PRIVATE METHODS
##############################

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
	
