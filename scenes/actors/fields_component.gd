extends Node2D

# Directional fields dictionary.
enum field_types {ORDERS, THREATS, TARGETS}
@onready var directional_fields = {
	field_types.ORDERS : DirectionalField.new(),
	field_types.THREATS : DirectionalField.new(),
	field_types.TARGETS : DirectionalField.new()
}

# Temporary var when combining all the fields in one
var combined_directional_field = DirectionalField.new()

# Parameters for Threats
const THREATS_RADIUS = 150
const THREATS_BASE_WEIGHT = 120
@onready var threats_weight = THREATS_BASE_WEIGHT

# Parameters for Orders
const ORDERS_BASE_WEIGHT = 5
@onready var orders_weight = ORDERS_BASE_WEIGHT

# Parameters for Targets
var TARGETS_RADIUS = 300
var TARGETS_MIN_RADIUS = 100
var TARGETS_BASE_WEIGHT = 4
@onready var targets_weight = TARGETS_BASE_WEIGHT

# Reference to the Navigation Field:
var navigation_component = Resource

##############################
## INTERFACE
##############################

func get_combined_field_peak() -> Vector2:
	
	# TODO can be optimized a LOT!
	combined_directional_field.clear_current()
	combined_directional_field.combine(directional_fields[field_types.ORDERS], orders_weight)
	combined_directional_field.combine(directional_fields[field_types.THREATS], threats_weight)
	combined_directional_field.combine(directional_fields[field_types.TARGETS], targets_weight)
	
	# For debug use:
	combined_directional_field.display_debug(get_parent().position)
	
	return combined_directional_field.get_peak().normalized()

##############################
## LOOPS
##############################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(combined_directional_field)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	_update_orders_field(delta)
	_update_threats_field(delta)
	_update_targets_field(delta)
		
	pass

##############################
## PRIVATE METHODS
##############################

# Threat field pushes the goon away from threats if too close
func _update_threats_field(delta: float):
	directional_fields[field_types.THREATS].clear_buffer()
	for goon in get_tree().get_nodes_in_group("goons"):
		var range = get_parent().position.distance_to(goon.position)
		
		if goon.FACTION != get_parent().FACTION and range < THREATS_RADIUS:
			var threat_angle = (goon.position - get_parent().position).angle() + PI
			var threat_value = abs((THREATS_RADIUS - range)) / THREATS_RADIUS
			
			directional_fields[field_types.THREATS].add_effect(threat_value, threat_angle) 
			
			if goon.FACTION == 1:
				##print("goon spotted threat. distance is ", range, " , value is ", threat_value, ".")
				pass
		
		# Finally combining it all in the next "stable" field.
		directional_fields[field_types.THREATS].set_step(delta)
		
# Order brings the goon in the direction of the objective.
func _update_orders_field(delta: float):
	directional_fields[field_types.ORDERS].clear_buffer()
	var temp_vector = navigation_component.get_move()
	if temp_vector:
		temp_vector -= get_parent().position
		
		# Creating the order by adding multiple effects to the field...
		directional_fields[field_types.ORDERS].add_effect(1, temp_vector.angle()) 
		
		# Finally combining it all in the next "stable" field.
		directional_fields[field_types.ORDERS].set_step(delta)

# Target field attracts goons to enemy goons, to a minimum distance.
# It has the tendency to distract goosn from their main directive, though.
func _update_targets_field(delta: float):
	directional_fields[field_types.TARGETS].clear_buffer()
	for goon in get_tree().get_nodes_in_group("goons"):
		var range = get_parent().position.distance_to(goon.position)
		if goon.FACTION != get_parent().FACTION and range < TARGETS_RADIUS and range > TARGETS_MIN_RADIUS:
			var target_angle = (goon.position - get_parent().position).angle()
			var target_value = 1 # TODO make it variables 
			
			directional_fields[field_types.TARGETS].add_effect(1, target_angle) 
		
		# Finally combining it all in the next "stable" field.
		directional_fields[field_types.TARGETS].set_step(delta)
