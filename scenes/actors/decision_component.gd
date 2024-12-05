extends Node2D

# Decision Component relies on the current types of groups to exist:
# - "goons" -> all kinds of units
# - "checkpoints" -> targets that you might want to reach and control
# - "cover" -> all cover elements

# Low period usage.
const DECISION_PERIOD_S = 0.2
var elapsed_time = 0

# Parameters
@export var NOTICE_SPEED = 10 # How fast alert grows
@export var SPOT_RANGE_CLOSE = 200 # while in green-yellow alert
@export var SPOT_RANGE_LONG = 500 # while in red alert.

# Internal Alert System
var alert_level : float = 0
const YELLOW_THRESHOLD : float = 1
const RED_THRESHOLD : float = 2

var is_in_cover : bool = false
var is_shooting : bool = false

# Local decision variables
var current_target_enemy = null
var latest_decision : Decision = null
const MIN_RANGE_TO_NEW_TARGET = 50
const MAX_DECISION_PERIOD_MS = 1000
var latest_decision_time = 0

# Introducing ORDERS.
enum Order {NONE, ADVANCE, DEFEND, SCATTER}
var order = Order.ADVANCE

# Temp TODO TBR?
var default_pref_y : float = 0 # between 0 and 1.
@export var FORMATION_DEPTH = 600

##############################
## PUBLIC METHODS
##############################

func get_decision() -> Decision:
	var out_decision = Decision.new()
	
	# If low alert, a simple movement would do.
	if alert_level < YELLOW_THRESHOLD:
		
		# Search for the next checkpoint.
		var all_checkpoints = get_tree().get_nodes_in_group("checkpoints")
		if all_checkpoints and not all_checkpoints.is_empty(): 
		
			# Checking for each checkpoint if it's reachable, and finding the closer to reach. 
			var min_distance = 999999
			var chosen_checkpoint = null
			for checkpoint in all_checkpoints:
				if _range_to(checkpoint) < min_distance:
					min_distance = _range_to(checkpoint)
					chosen_checkpoint = checkpoint
			
			if chosen_checkpoint != null:
				var temp_weight = 1. # TODO this should be evaluated properly.
				return _create_out_decision(Decision.Types.MOVE, chosen_checkpoint, 1)
		
		# If no checkpoints are there, check the orders.
		match order:
			Order.ADVANCE: 
				# If the order is too far, don't look for a new one.
				if latest_decision and latest_decision.type == Decision.Types.MOVE:
					if	_range_to(latest_decision.target) > MIN_RANGE_TO_NEW_TARGET and\
						#latest_decision.get_target_position().x > get_parent().global_position.x and\
						Time.get_ticks_msec() - latest_decision_time < MAX_DECISION_PERIOD_MS:
						return latest_decision
				
				latest_decision_time = Time.get_ticks_msec()
				
				# Setting a "in front of you" sort of target, which keeps getting updated.
				var steps = 32
				var step_size = get_viewport().size.y / (steps + 1)
				var preferred_y = get_viewport().size.y * default_pref_y
				var containing_rect = Utilities.get_latest_containing_rect_for_faction(get_parent().FACTION)
				var x_position = containing_rect.position.x + FORMATION_DEPTH
				if get_parent().FACTION != 1:
					x_position = containing_rect.position.x + containing_rect.size.x - FORMATION_DEPTH
				for i in range (steps):
					var y_offset = preferred_y + get_viewport().size.y
					var direction = 1 if (i % 2 == 0) else -1
					y_offset += direction * step_size * i
					y_offset = int(y_offset) % get_viewport().size.y # lol mod doesn't work well 
					var new_position = Vector2(x_position, y_offset)
					if Utilities.is_point_in_collision_area(new_position):
						continue
					
					var temp_weight = 1. # TODO this should be evaluated properly.
					return _create_out_decision(Decision.Types.MOVE, new_position, 1)
				print("WARNING! NO DESTINATION FOUND FOR GOON ", get_parent())
				pass
				
			_: 
				# not implemented orders
				pass
					
	# Case Attack
	if alert_level > RED_THRESHOLD:
		var selected_target = _get_best_target(min(get_parent().WEAPON_RANGE, _get_spot_range()))
		if selected_target:
			out_decision.type = Decision.Types.ATTACK
			out_decision.target = selected_target
			out_decision.weight = 1 # TODO this should be calculated!
			
			## Returning decision ATTACK
			return out_decision 
			
	# If medium alert, there's movement towards things that are suspicious.
	var selected_target = _get_best_target(_get_spot_range())
	if selected_target != null:
		out_decision.type = Decision.Types.PURSUE
		out_decision.target = selected_target
		out_decision.weight = 1 # TODO this should be evaluated properly.
		
		## Returning decision PURSUE
		return out_decision

	
	# TODO COVER!!!
	
	## Returning decision IDLE
	return out_decision

##############################
## LOOPS
##############################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_pref_y = randf()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	elapsed_time += delta
	if elapsed_time > DECISION_PERIOD_S:
		
		# TODO this could be done more rarely, for optimization
		# Checking whether to increase or decrease the attention.
		var nearby_threats = _get_targets(_get_spot_range()).size()
		if nearby_threats == 0:
			alert_level -= elapsed_time * NOTICE_SPEED
		else:
			alert_level += elapsed_time * NOTICE_SPEED * sqrt(float(nearby_threats))
		alert_level = clamp(alert_level, 0, RED_THRESHOLD * 2)
		
		if alert_level > YELLOW_THRESHOLD:
			get_parent().get_node("DebugLabel").text = "??"
		if alert_level > RED_THRESHOLD:
			get_parent().get_node("DebugLabel").text = "!!!"
		
		# Resetting the elapsed time.
		elapsed_time = 0

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
	for goon in UnitsRegister.get_goons(faction):
		
		if not is_instance_valid(goon):
			continue
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
		var raycast_query = PhysicsRayQueryParameters2D.create(get_parent().global_position, target_object.global_position, get_parent().collision_mask, [self, target_object])
		var raycast_result = space_state.intersect_ray(raycast_query)
		if raycast_result.is_empty():
			return true
	return false

func _range_to(target) -> float:
	match typeof(target):
		TYPE_OBJECT: 	return get_parent().global_position.distance_to(target.global_position)
		TYPE_VECTOR2: 	return get_parent().global_position.distance_to(target)
		_: 				return 0			
	
func _create_out_decision(type : Decision.Types, target, weight: float) -> Decision:
	var out_decision = Decision.new()
	out_decision.type = type
	out_decision.target = target
	out_decision.weight = weight # TODO this should be evaluated properly.
	
	## Returning decision PURSUE
	latest_decision = out_decision
	return out_decision
