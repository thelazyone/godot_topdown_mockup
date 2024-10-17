extends Node2D

enum orders {IDLE, ATTACK, DEFEND}

var current_order = orders.IDLE
var target_area = Vector2.ZERO
var target_position = Vector2.ZERO
var target_radius = 0. # In the future the radius can be set dragging in-game

# Enemy Targeting 
var target_enemy = null
const SPOTTING_RANGE = 300 # probably should be elsewhere

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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
		# Applying the decision logics
	if state == states.IDLE:
		_move() # not convinced that this is the right name. Should be "apply order"

	_check_spot()
	_check_retreat()
	
	# Now deciding the movement order: 
	_apply_strategy()


# Private Methods
func _set_new_order(order_type: orders, position: Vector2, radius):
	print("order of type ", order_type, " received for ", position, ".")
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
			target_position = Vector2.ZERO
			if current_order != orders.IDLE:
				print("changing state to MOVE")
				_get_position_in_area()
				state = states.MOVE
				return
			
		states.MOVE:
				#Position should be set already.
			pass
		
		states.PURSUE:
			if not target_enemy: 
				state = states.IDLE
				return
				
			target_position = target_enemy.position
			
		states.ATTACK:
			if not target_enemy: 
				state = states.IDLE
				return
				
			if !_is_in_range(target_enemy.position):
				_pursue(target_enemy)
				return
			
			if  get_parent().position.distance_to(target_enemy.position) > get_parent().RANGE:
				target_position = target_enemy.position
			
		states.EVADE:
			# No evasion implemented for now.
			pass
				
		_:
			print("WARNING, unexpected state: ", state)
		
# Decision Methods
func _check_spot() -> bool:
	
	# TODO this is tbr too - once locked, it doesn't allow for "a better target" to swtich.
	# But there should be a good logic for that, choosing among targets giving a soft preference
	# to the one already locked.
	if state == states.PURSUE:
		return false
	
	# TODO the spotting should have a better system. For now it's simply a "check if anything is 
	# within range, and pick just one.
	for goon in get_tree().get_nodes_in_group("goons"):
		if goon.FACTION != get_parent().FACTION and get_parent().position.distance_to(goon.position) < SPOTTING_RANGE:
			_pursue(goon) 
			return true
	return false
	
func _check_retreat() -> bool:
	# TODO the bravest never retreat! Still to implement.
	
	return false
	
func _is_in_range(target_position) -> bool:
	# TODO implement a better logic
	if get_parent().position.distance_to(target_position) < get_parent().RANGE:
		return true
	return false
	
func _move() -> Vector2:
	return Vector2.ZERO
	
func _pursue(target):
	target_enemy = target
	state = states.PURSUE

func _retreat():
	target_enemy = null
	state = states.EVADE
	
