extends Node2D

# Directional fields dictionary.
enum field_types {DECISION, THREATS, FORMATION}
@onready var directional_fields = {
	field_types.DECISION : DirectionalField.new(),
	field_types.THREATS : DirectionalField.new(),
	field_types.FORMATION : DirectionalField.new()
}
var combined_directional_field = DirectionalField.new()

@onready var decision_weight = 4
@onready var threats_weight = 30
@onready var formation_weight = 16

##############################
## INTERFACE
##############################

func set_decision_field(direction: float, delta: float):
	directional_fields[field_types.DECISION].clear_buffer()
	directional_fields[field_types.DECISION].add_effect(1, direction) 
	directional_fields[field_types.DECISION].set_step(delta)

func set_threat_field(threats: Array, threat_range: float, delta: float):
	directional_fields[field_types.THREATS].clear_buffer()
	for threat in threats:
		if 	not threat or not is_instance_valid(threat):
			continue
		var range = _range_to(threat)
		var effect_value = 1 * _hyperbolic_repulsion(threat_range, range) ## TODO THIS IS CLEARLY WRONG!
		var effect_angle = _angle_to(threat) + PI
		directional_fields[field_types.THREATS].add_effect(effect_value, effect_angle) 
	directional_fields[field_types.THREATS].set_step(delta)

func set_formation_field(allies: Array, formation_range: float, delta: float):
	directional_fields[field_types.FORMATION].clear_buffer()
	for ally in allies:
		if ally == get_parent():
			continue
		var effect_value = _elastic_attractor(formation_range, _range_to(ally))
		var effect_angle = _angle_to(ally)
		if effect_value < 0:
			effect_value *= -1
			effect_angle += PI
		directional_fields[field_types.FORMATION].add_effect(effect_value, effect_angle) 
	directional_fields[field_types.FORMATION].set_step(delta)

func get_combined_field_peak() -> Vector2:
	#
	## For debug use:
	#directional_fields[field_types.DECISION].display_debug(get_parent().global_position, Color.BLUE, decision_weight)
	#directional_fields[field_types.THREATS].display_debug(get_parent().global_position, Color.RED, threats_weight)
	#directional_fields[field_types.FORMATION].display_debug(get_parent().global_position, Color.GREEN, formation_weight)

	# TODO can be optimized a LOT!
	combined_directional_field.clear_current()
	combined_directional_field.combine(directional_fields[field_types.DECISION], decision_weight)
	combined_directional_field.combine(directional_fields[field_types.THREATS], threats_weight)
	combined_directional_field.combine(directional_fields[field_types.FORMATION], formation_weight)
	
	# For debug use:
	#combined_directional_field.display_debug(get_parent().global_position, Color.LIGHT_CYAN)
	
	return combined_directional_field.get_sum()

##############################
## LOOPS
##############################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(combined_directional_field)
	add_child(directional_fields[field_types.DECISION])
	add_child(directional_fields[field_types.THREATS])
	add_child(directional_fields[field_types.FORMATION])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

##############################
## PRIVATE METHODS
##############################

## A linear attractor around spring_range, pushing away from r = 0 and r = 2 * spring_range
func _elastic_attractor(spring_range: float, current_range: float):
	return  min(spring_range, (current_range - spring_range)) / spring_range

## A 1/x repulsion, with a max repel of 1
func _hyperbolic_repulsion(spring_range: float, current_range: float):
	return 1/(1 + min(1, current_range/spring_range))
	
## Global range to node
func _range_to(target : Node) -> float:
	return get_parent().global_position.distance_to(target.global_position)

## Global angle to node
func _angle_to(target: Node) -> float:
	return Geometry.wrap_angle(get_parent().global_position.angle_to_point(target.global_position))
	
