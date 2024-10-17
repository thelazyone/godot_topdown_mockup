extends Node2D

enum order {IDLE, ATTACK, DEFEND}

var current_order = order.IDLE
var target_area = Vector2.ZERO
var target_position = Vector2.ZERO
var target_radius = 0. # In the future the radius can be set dragging in-game


# State Machine 
enum states {IDLE, MOVE, PURSUE, ATTACK, EVADE}
var state = states.IDLE


# Public Commands:
func attack(position: Vector2, radius = 50):
	_set_new_order(order.ATTACK, position, radius)
	
	
func defend(position: Vector2, radius = 50):
	_set_new_order(order.DEFEND, position, radius)


func get_next_move():
	# TODO next move should be something related with Pursue or Move depending.
	print("test",target_position)
	return target_position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Applying the decision logics - if in the wrong state it is ignored.
	_move() 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Private Methods
func _set_new_order(order_type: order, position: Vector2, radius):
	current_order = order_type
	target_area = position
	target_radius = radius
	print ("target area is ", target_area, ", target radius is ", target_radius)
	_choose_destination()


func _choose_destination(): 
	
	# In the future the logic to choose one area over another should depend on
	# what other units are doing: a target position gets "registered" somewhere
	# globally and you directly aim for another position instead.
	# For now, it's just a random pos in the circle.
	target_position = target_area + Vector2(1,0).rotated(randf()*2*PI)*randf()*target_radius
	
	
# Decision Methods
func _spot() -> bool:
	return false
	
func _retreat() -> bool:
	return false
	
func _is_in_range() -> bool:
	return false
	
func _move() -> Vector2:
	return Vector2.ZERO

	
