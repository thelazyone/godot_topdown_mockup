extends Node2D

# Directional fields dictionary.
enum field_types {DECISION, THREATS, FORMATION}
@onready var directional_fields = {
	field_types.DECISION : DirectionalField.new(),
	field_types.THREATS : DirectionalField.new(),
	field_types.FORMATION : DirectionalField.new()
}

const UPDATE_PERIOD_S = .1
var last_update_time = 0

# Temporary var when combining all the fields in one
var combined_directional_field = DirectionalField.new()

@onready var decision_weight = 4
@onready var threats_weight = 10
@onready var formation_weight = 8

##############################
## INTERFACE
##############################

func set_decision_field(direction: Vector2, weight: Float):
	directional_fields[field_types.DECISION].clear_buffer()
	directional_fields[field_types.TARGETS].add_effect(effect_value,effect_angle ) 

	# Finally combining it all in the next "stable" field.
	directional_fields[field_types.TARGETS].set_step(delta)
	

func get_combined_field_peak() -> Vector2:
	
	# TODO can be optimized a LOT!
	combined_directional_field.clear_current()
	combined_directional_field.combine(directional_fields[field_types.DECISION], decision_weight)
	combined_directional_field.combine(directional_fields[field_types.THREATS], threats_weight)
	combined_directional_field.combine(directional_fields[field_types.FORMATION], formation_weight)
	
	# For debug use:
	combined_directional_field.display_debug(get_parent().global_position)
	
	return combined_directional_field.get_composite_result().normalized()

##############################
## LOOPS
##############################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(combined_directional_field)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	last_update_time += delta
	if last_update_time > UPDATE_PERIOD_S:
		last_update_time = 0
		
		_update_decision_field(delta)
		_update_threats_field(delta)
		_update_formation_field(delta)
		
	pass

##############################
## PRIVATE METHODS
##############################

# Threat field pushes the goon away from threats if too close
func _update_threats_field(delta: float):
	directional_fields[field_types.THREATS].clear_buffer()
	#for goon in get_tree().get_nodes_in_group("goons"):
		#var range = get_parent().global_position.distance_to(goon.global_position)
		#
		#if goon.FACTION != get_parent().FACTION and range < threats_range:
			#
			## The direction is opposite (+PI) of the versor between the two.
			#var effect_angle = (goon.global_position - get_parent().global_position).angle() + PI
			#
			## Note that the repulsion is never really big because the distance between goons is
			## always a minimum of 2*range
			#var effect_value = 1 * _hyperbolic_repulsion(threats_range, range)
			#
			#directional_fields[field_types.THREATS].add_effect(effect_value, effect_angle) 
			#
			#if goon.FACTION == 1:
				#pass
		
	# Finally combining it all in the next "stable" field.
	directional_fields[field_types.THREATS].set_step(delta)
	

# Target field attracts goons to enemy goons, to a minimum distance.
# It has the tendency to distract goosn from their main directive, though.
func _update_targets_field(delta: float):
	
	directional_fields[field_types.TARGETS].clear_buffer()
	
	if strategy_component.target_enemy and is_instance_valid(strategy_component.target_enemy):
		navigation_component.set_target(strategy_component.target_enemy.global_position)
		var temp_vector = navigation_component.get_move()
		var range = get_parent().global_position.distance_to(strategy_component.target_enemy.global_position)

		if temp_vector and range < targets_range:
			temp_vector -= get_parent().global_position
			var effect_angle = temp_vector.angle()
			directional_fields[field_types.TARGETS].add_effect(1, effect_angle) 
			
			# If closer than min, it's repulsive!
			if range <    targets_min_range:
				var effect_value = 2 * _elastic_repulsion(targets_min_range, range)
				effect_angle += PI
				directional_fields[field_types.TARGETS].add_effect(effect_value,effect_angle ) 

	# Finally combining it all in the next "stable" field.
	directional_fields[field_types.TARGETS].set_step(delta)


# Checks if there are allies nearby, and pushes them away a bit.
func _update_formation_field(delta: float):
	
	directional_fields[field_types.FORMATION].clear_buffer()
	
	for goon in get_tree().get_nodes_in_group("goons"):
		
		# Don't compare with itself.
		if goon == get_parent(): 
			continue
		
		# If too close, spring moves it away a bit.
		var range = get_parent().global_position.distance_to(goon.global_position)
		if goon.FACTION == get_parent().FACTION and range < formation_distance:
			var effect_angle = get_parent().get_angle_to(goon.global_position) + PI
			var effect_value = 1 * _elastic_repulsion(formation_distance, range)
			
			directional_fields[field_types.FORMATION].add_effect(effect_value, effect_angle) 
		
	# Finally combining it all in the next "stable" field.
	directional_fields[field_types.FORMATION].set_step(delta)

# A linear repulsion, with a max repel of 1
func _elastic_repulsion(spring_range: float, current_range: float):
	return abs(spring_range - current_range) / spring_range

# A 1/x repulsion, with a max repel of 1
func _hyperbolic_repulsion(spring_range: float, current_range: float):
	return 1/(1 + min(1, current_range/spring_range))
