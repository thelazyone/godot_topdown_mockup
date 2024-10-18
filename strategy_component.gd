extends Node2D

enum orders {NONE, ATTACK, DEFEND}

var current_order = orders.NONE
var target_area = Vector2.ZERO
var target_position = Vector2.ZERO
var position_margin = 20
var target_radius = 0. # In the future the radius can be set dragging in-game

# Enemy Targeting 
var target_enemy = null

# State Machine 
enum states {IDLE, MOVE, PURSUE, ATTACK, EVADE}
var state = states.IDLE


# Public Commands:
func attack(position: Vector2, radius = 50):
	_set_new_order(orders.ATTACK, position, radius)
	
	
func defend(position: Vector2, radius = 50):
	_set_new_order(orders.DEFEND, position, radius)


func get_next_move():
	# TODO next move should be something related with Pursue or Move depending.
	return target_position

func get_shoot_target():
	if target_enemy and state == states.ATTACK:
		return target_enemy.position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	_spot()
	_check_retreat()
	
	# Now deciding the movement order: 
	_apply_strategy()


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
	print("Goon of faction ", get_parent().FACTION, " changing state: ",_state_number_to_name(state),"->",_state_number_to_name(new_state))
	state = new_state

func _set_new_order(order_type: orders, position: Vector2, radius):
	current_order = order_type
	target_area = position
	target_radius = radius
	_get_position_in_area()
	
	
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
			target_position = get_parent().position
			if current_order != orders.NONE:
				_get_position_in_area()
				
				if target_position.distance_to(get_parent().position) > position_margin:
					_set_state(states.MOVE)
				else:
					target_position = get_parent().position
				return
			
		states.MOVE:
				#Position should be set already.
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
				#print("nope, too close!")
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
	
	# TODO magic numbers here, for now. TBR.
	
	# Implementing a hysteresis here.
	if (state == states.PURSUE or state == states.ATTACK):
		if get_parent().position.distance_to(target_area) > get_parent().SPOTTING_RANGE + target_radius: 
			print ("break pursue")
			return false 
		
	elif get_parent().position.distance_to(target_area) > target_radius:
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
	
func _pursue(target):
	target_enemy = target
	_set_state(states.PURSUE)

func _retreat():
	target_enemy = null
	_set_state(states.EVADE)
	
