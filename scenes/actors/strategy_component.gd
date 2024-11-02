extends Node2D

enum orders {NONE, ATTACK, DEFEND}

var current_order = orders.NONE
const ORDER_PERIOD_S = .05
var last_order_time_s = 99

var target_area = Vector2.ZERO
var target_position = Vector2.ZERO
const POSITION_MARGIN = 20
var target_radius = 0. # In the future the radius can be set dragging in-game
var last_position_before_pursue = Vector2.ZERO # TEMP TODO TBR?

# Directional fields dictionary.
enum field_types {ORDERS, THREATS, TARGETS}
@onready var directional_fields = {
	field_types.ORDERS : DirectionalField.new(),
	field_types.THREATS : DirectionalField.new(),
	field_types.TARGETS : DirectionalField.new()
}
var support_directional_field = DirectionalField.new()
const THREAT_RADIUS = 200
const THREAT_BASE_WEIGHT = 7
const ORDER_BASE_WEIGHT = 5
const TARGET_RADIUS = 300
const TARGET_MIN_RADIUS = 80
const TARGET_BASE_WEIGHT = 4


# For the Navigation Field:
var navigation_component = Resource

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

# Direct mouse commands
func go_to(position: Vector2, radius = 50): # TODO TBR
	_set_new_order(orders.DEFEND, position, radius)

# Main output
func get_next_move():
	if state != states.IDLE:
		return get_parent().position + _get_combined_field_peak()
		return navigation_component.get_move(target_position)
	return null

# Shooting logic
func is_shooting():
	if target_enemy and is_instance_valid(target_enemy) and state == states.ATTACK:
		return target_enemy.position

##############################
## PRIVATE METHODS
##############################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Nothing here.
	add_child(support_directional_field)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	_spot()
	_check_retreat()
	
	# If necessary, evaluating order.
	last_order_time_s += delta
	if last_order_time_s > ORDER_PERIOD_S:
		last_order_time_s = 0
		_choose_new_order()
		
		# Testing out the Fields:
		_update_orders_field(delta)
		_update_threats_field(delta)

		# Now deciding the movement: 
		_apply_strategy()


# Threat field pushes the goon away from threats if too close
func _update_threats_field(delta: float):
	directional_fields[field_types.THREATS].clear_buffer()
	for goon in get_tree().get_nodes_in_group("goons"):
		var range = get_parent().position.distance_to(goon.position)
		if goon.FACTION != get_parent().FACTION and range < THREAT_RADIUS:
			var threat_angle = (goon.position - get_parent().position).angle() + PI
			var threat_value = THREAT_BASE_WEIGHT * (THREAT_RADIUS - range) / THREAT_RADIUS
			
			directional_fields[field_types.THREATS].add_effect(threat_value, threat_angle) 
		
		# Finally combining it all in the next "stable" field.
		directional_fields[field_types.THREATS].set_step(delta)
		
# Order brings the goon in the direction of the objective.
func _update_orders_field(delta: float):
	directional_fields[field_types.ORDERS].clear_buffer()
	var temp_vector = navigation_component.get_move(target_position)
	if temp_vector:
		temp_vector -= get_parent().position
		
		# Creating the order by adding multiple effects to the field...
		directional_fields[field_types.ORDERS].add_effect(ORDER_BASE_WEIGHT, temp_vector.angle()) 
		
		# Finally combining it all in the next "stable" field.
		directional_fields[field_types.ORDERS].set_step(delta)

# Target field attracts goons to enemy goons, to a minimum distance.
# It has the tendency to distract goosn from their main directive, though.
func _update_targets_field(delta: float):
	directional_fields[field_types.TARGETS].clear_buffer()
	for goon in get_tree().get_nodes_in_group("goons"):
		var range = get_parent().position.distance_to(goon.position)
		if goon.FACTION != get_parent().FACTION and range < TARGET_RADIUS and range > TARGET_MIN_RADIUS:
			var target_angle = (goon.position - get_parent().position).angle()
			var target_value = TARGET_BASE_WEIGHT 
			
			directional_fields[field_types.TARGETS].add_effect(target_value, target_angle) 
		
		# Finally combining it all in the next "stable" field.
		directional_fields[field_types.TARGETS].set_step(delta)

# Private Methods
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

# Called periodically, to decide what to do.
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
	target_position = target_area
	target_radius = radius
	_get_position_in_area()
	navigation_component.set_target(target_position)

	
func _get_position_in_area():
	# In the future the logic to choose one area over another should depend on
	# what other units are doing: a target position gets "registered" somewhere
	# globally and you directly aim for another position instead.
	# For now, it's just a random pos in the circle.
	target_position = target_area + Vector2(1,0).rotated(randf()*2*PI)*randf()*target_radius

func _apply_strategy(): 
	match state:
		states.IDLE:
			# In the future there should be some random walk, TODO.			
			if current_order != orders.NONE:
				
				if not _is_in_place(target_position):
					_get_position_in_area()
					_set_state(states.MOVE)
				else:
					target_position = get_parent().position
				return
			
		states.MOVE:
			
			if _is_in_place(target_position):
				_set_state(states.IDLE)
			pass
		
		states.PURSUE:
			if not target_enemy: 
				_set_state(states.IDLE)
				return
				
			if _is_in_range(target_enemy.position):
				_set_state(states.ATTACK)
			else:
				target_position = target_enemy.position
			
		states.ATTACK:
			if not target_enemy: 
				_set_state(states.IDLE)
				return
				
			if !_is_in_range(target_enemy.position):
				_pursue(target_enemy)
				return
			
			# TODO now, this is to allow to get closer even when attacking.
			# there should be a damage increment when getting closer.
			if  get_parent().position.distance_to(target_enemy.position) > get_parent().WEAPON_RANGE / 2:
				#print("approach during attack")
				target_position = target_enemy.position
			else: 
				target_position = get_parent().position
			
		states.EVADE:
			# No evasion implemented for now.
			pass
				
		_:
			print("WARNING, unexpected state: ", state)
		
		
# Decision Methods
func _spot():
	# TODO the spotting should have a better system. For now it's simply a "check if anything is 
	# within range, and pick just one.
	
	var should_spot = _evaluate_spot()
	
	# Finding any target, if found pursue.
	if (state == states.IDLE or state == states.MOVE) and should_spot:
		var spotting_range = get_parent().SPOTTING_RANGE
		if state == states.MOVE:
			spotting_range *= .25
		for goon in get_tree().get_nodes_in_group("goons"):
			if goon.FACTION != get_parent().FACTION and get_parent().position.distance_to(goon.position) < spotting_range:
				_pursue(goon) 
	
	elif state == states.PURSUE or state == states.ATTACK and not should_spot:
		# TODO what about EVADE?
		_set_state(states.IDLE)

	
func _evaluate_spot() -> bool:
	
	# Considering (for now)
	# - distance from objective
	var distance_to_target = get_parent().position.distance_to(target_area)
	
	# TODO magic numbers here, for now. TBR.
	
	# Implementing a hysteresis here.
	if (state == states.PURSUE or state == states.ATTACK):
		if distance_to_target > get_parent().SPOTTING_RANGE + target_radius: 
			return false 
		
	elif distance_to_target > target_radius:
		#print ("break spot on state ", _state_number_to_name(state))
		return false
	
	return true
	
	
func _check_retreat() -> bool:
	# TODO the bravest never retreat! Still to implement.
	
	return false
	
func _is_in_range(target_position) -> bool:
	# TODO implement a better logic
	if get_parent().position.distance_to(target_position) < get_parent().WEAPON_RANGE:
		return true
	return false

func _is_in_place(target_position) -> bool:
	if get_parent().position.distance_to(target_position) < POSITION_MARGIN:
		return true
	return false
	
func _pursue(target):
	target_enemy = target
	_set_state(states.PURSUE)

func _retreat():
	target_enemy = null
	_set_state(states.EVADE)
	
	
# Navigation stuff:
func _get_combined_field_peak() -> Vector2:
	
	# TODO can be optimized a LOT!
	support_directional_field.clear_current()
	support_directional_field.combine(directional_fields[field_types.ORDERS])
	support_directional_field.combine(directional_fields[field_types.THREATS])
	#support_directional_field.combine(directional_fields[field_types.TARGETS])
	
	# For debug use:
	support_directional_field.display_debug(get_parent().position)
	
	return support_directional_field.get_peak().normalized()
