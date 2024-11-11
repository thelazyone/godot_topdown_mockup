extends Node2D

# Orders vars. Currently always using DEFEND.
enum orders {NONE, PATROL, DEFEND}
var current_order = orders.NONE
const ORDER_PERIOD_S = .1
var last_order_time_s = 99

var target_area = Vector2.ZERO
var target_position = Vector2.ZERO
const POSITION_MARGIN = 20
var target_radius = 0. # In the future the radius can be set dragging in-game
var last_position_before_pursue = Vector2.ZERO # TEMP TODO TBR?

# Navigation is accessed directly from the Strategy Component
var navigation_component = Resource
var fields_component = Resource

# Enemy Targeting 
var target_enemy = null

# State Machine 
# Each state gives different weights to the directional fields, regulating
# the behaviour accordingly.
enum states {IDLE, MOVE, PURSUE, ATTACK, EVADE}
var state = states.IDLE

##############################
## INTERFACE
##############################

# Proper interface should set general behaviour patterns.

# Direct mouse commands
# Temporary
func go_to(position: Vector2, radius = 50): # TODO TBR
	_set_new_order(orders.DEFEND, position, radius)

# Main output. Returns the point where the Goon should move.
# The pathfinding is already calculated, so you should just apply this to any logic in the goon.
func get_next_move():
	if state != states.IDLE:
		return get_parent().position + fields_component.get_combined_field_peak()
		return navigation_component.get_move(target_position)
	return null

# Shooting logic, to check whether to generate bullets. Returns the target point to shoot towards.
func get_shooting_target():
	if target_enemy and is_instance_valid(target_enemy):
		return target_enemy.position

##############################
## LOOPS
##############################

func _ready() -> void:
	# Nothing here.
	pass

func _process(delta: float) -> void:

	# First searching the closest enemy, which is the target.
	_search_enemy_targets() # returns true if there is a target
	
	# Evaluating strategy periodically.
	last_order_time_s += delta
	if last_order_time_s > ORDER_PERIOD_S:
		last_order_time_s = 0
		
		_choose_new_order()
		
		# Now deciding the movement: 
		_apply_strategy()

##############################
## PRIVATE METHODS
##############################

# For debug purposes
func _state_number_to_name(state_number: int) -> String:
	match state_number:
		0: return "IDLE"
		1: return "MOVE"
		2: return "PURSUE"
		3: return "ATTACK"
		4: return "EVADE"
		_: return "UNKNOWN"

func _set_state(new_state: states):
	#print("Goon of faction ", get_parent().FACTION, " changing state: ",_state_number_to_name(state),"->",_state_number_to_name(new_state))
	state = new_state

# Called periodically, to set the "node to control", based on various criteria.
# Note that this is not the state of the goon, just the general order that the 
# goon should be following if there is nothing else happening.
func _choose_new_order():
	
	var target_value : float
	match get_parent().FACTION:
		1: target_value = 1
		2: target_value = 0
	
	# TODO Current logic is: "check if there's a node that is not ours, and go there"
	# It's very basica but it might work for now.
	var all_checkpoints = get_tree().get_nodes_in_group("checkpoints")
	if not all_checkpoints: 
		_end_order()
		return
	var goon_pos = get_parent().position
	var nearest_checkpoint = null
	for checkpoint in all_checkpoints:
		if abs (checkpoint.CONTROL_FACTION - target_value) > 0.1: 
			if not nearest_checkpoint:
				nearest_checkpoint = checkpoint
			elif goon_pos.distance_to(checkpoint.position) < goon_pos.distance_to(nearest_checkpoint.position):
				nearest_checkpoint = checkpoint
	
	if not nearest_checkpoint:
		_end_order()
		return
	
	_set_new_order(orders.DEFEND, nearest_checkpoint.position, 100)
	
func _end_order():
	current_order = orders.NONE

func _set_new_order(order_type: orders, position: Vector2, radius):
	current_order = order_type
	target_area = position
	target_radius = radius
	_update_target_position(_get_position_in_area())
	
func _update_target_position(new_position):
	target_position = new_position
	navigation_component.set_target(new_position)
	
func _get_position_in_area():
	# In the future the logic to choose one area over another should depend on
	# what other units are doing: a target position gets "registered" somewhere
	# globally and you directly aim for another position instead.
	# For now, it's just a random pos in the circle.
	return  target_area + Vector2(1,0).rotated(randf()*2*PI)*randf()*target_radius

func _apply_strategy(): 
	match state:
		
		states.IDLE:
			# In the future there should be some random walk, TODO.			
			if current_order != orders.NONE:
				
				if not _is_in_place(target_position):
					_update_target_position(_get_position_in_area())
					_set_state(states.MOVE)
				#else:
					#_update_target_position(get_parent().position)
				return
			
		states.MOVE:
			
			if _is_in_place(target_position):
				_set_state(states.IDLE)
			pass
		
		states.PURSUE:
			if not target_enemy: 
				_set_state(states.IDLE)
				return
				
			if _is_in_weapon_range(target_enemy.position):
				_set_state(states.ATTACK)
			else:
				_update_target_position(target_enemy.position)
			
		states.ATTACK:
			if not target_enemy: 
				_set_state(states.IDLE)
				return
				
			if !_is_in_weapon_range(target_enemy.position):
				_pursue(target_enemy)
				return
			
			# TODO now, this is to allow to get closer even when attacking.
			# there should be a damage increment when getting closer.
			if  get_parent().position.distance_to(target_enemy.position) > get_parent().WEAPON_RANGE / 2:
				#print("approach during attack")
				_update_target_position(target_enemy.position)
			else: 
				_update_target_position(get_parent().position)
			
		states.EVADE:
			# No evasion implemented for now.
			pass
				
		_:
			print("WARNING, unexpected state: ", state)
		
# Decision Methods

# Spotting simply implies finding or not enemy targets within range. If one is selected already
# there is a bit of a hysteresis before a new one is selected.
# TODO use a raycast2d node to see if there is collison.
func _search_enemy_targets():
	
	# Looping on all the goons that are not 
	var spotting_range : float = get_parent().SPOTTING_RANGE
	
	# Searching for the closest. However, if there's a target already the new one should be a bit
	# quite a bit closer than that. This avoid constant switching.
	var closest_range : float = 99999
	if target_enemy and is_instance_valid(target_enemy):
		closest_range = _range_to(target_enemy) * .9

	for goon in get_tree().get_nodes_in_group("goons"):
		if goon.FACTION != get_parent().FACTION:
			var target_distance = _range_to(goon)
			if target_distance < spotting_range and target_distance < closest_range:
				closest_range = target_distance
				_set_target(goon)
			pass
			
	return target_enemy != null
	
func _range_to(target : Node) -> float:
	return get_parent().position.distance_to(target.position)
	
func _set_target(target: Node):
	target_enemy = target


# TODO PROBABLY TO PURGE



	
func _check_retreat() -> bool:
	# TODO the bravest never retreat! Still to implement.
	
	return false
	
func _is_in_weapon_range(input_position) -> bool:
	# TODO implement a better logic
	if get_parent().position.distance_to(input_position) < get_parent().WEAPON_RANGE:
		return true
	return false

func _is_in_place(input_position) -> bool:
	if get_parent().position.distance_to(input_position) < POSITION_MARGIN:
		return true
	return false
	
# State change commands
	
func _pursue(target):
	target_enemy = target
	_set_state(states.PURSUE)

func _retreat():
	target_enemy = null
	_set_state(states.EVADE)
