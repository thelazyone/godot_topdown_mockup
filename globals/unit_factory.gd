extends Node
const goon_scene = preload("res://scenes/actors/goon.tscn")

# Periodic processing
const UNIT_CHECK_PERIOD_MS = 100

# To optimize, the containing rect is calculated only every now and then.
var elapsed_times = {}
var latest_containing_rects = {}

func get_latest_containing_rect_for_faction(i_faction : int) -> Rect2:
	if not i_faction in latest_containing_rects or not i_faction in elapsed_times:
		return _update_containing_rect_for_faction(i_faction)
		
	if Time.get_ticks_msec() - elapsed_times[i_faction] > UNIT_CHECK_PERIOD_MS:
		return _update_containing_rect_for_faction(i_faction)
	
	return latest_containing_rects[i_faction]

func force_get_containing_rect_for_faction(i_faction : int) -> Rect2:
	return _update_containing_rect_for_faction(i_faction)

# Public Method
func create_unit_by_type(i_type : UnitParams.Types, i_position: Vector2, i_id: int, i_faction: int,) -> Node:
	return create_unit(UnitParams.get_unit_params(i_type), i_position, i_id, i_faction)

func create_unit(i_params: UnitParams, i_position: Vector2, i_id: int, i_faction: int,) -> Node:
	
	var goon = goon_scene.instantiate()
	goon.position = i_position
	goon.FACTION = i_faction
	goon.ID = i_id
	goon.add_to_group("goons")
	add_child(goon)
	
	# General Params
	goon.NAME = i_params.name_id
	goon.health.health = i_params.hp
	goon.get_node("Image").texture = load(i_params.icon)
	goon.SPEED = i_params.speed
	goon.SPOTTING_RANGE = i_params.spotting_range
	goon.decision.SPOT_RANGE_LONG = i_params.spotting_range * 2
	goon.decision.SPOT_RANGE_CLOSE = i_params.spotting_range 

	# Attack Params
	goon.shoot.COOLDOWN_TIME_MS = i_params.attack_speed
	goon.shoot.PROJECTILE.DAMAGE = i_params.attack_damage
	goon.shoot.PROJECTILE.DURATION_MS = i_params.attack_range * 2
	goon.shoot.PROJECTILE.UNIT_ID = goon.ID
	goon.WEAPON_RANGE = i_params.attack_range

	# Behaviour Fields Params
	# Threats Field
	goon.field.threats_weight = i_params.threats_weight
	goon.THREAT_RANGE = i_params.threats_range

	# Orders Field
	goon.field.decision_weight = i_params.decision_weight
	#if goon.FACTION != 1:
		#goon.field.decision_weight = 0
	#else:
		#goon.field.decision_weight = i_params.decision_weight

	match goon.FACTION:
		1: goon.get_node("Image").self_modulate = Color.ROYAL_BLUE
		2: goon.get_node("Image").self_modulate = Color.PALE_VIOLET_RED
		3: goon.get_node("Image").self_modulate = Color.LIGHT_GREEN
		_: goon.get_node("Image").self_modulate = Color.WEB_GRAY
	
	if goon.FACTION != 1:
		goon.default_facing_right = false	
	return goon
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#last_elapsed += delta
	#if last_elapsed > PROCESSING_TIME_S:
		#last_elapsed = 0
		#_update_containing_rect_for_faction(1)
		
	pass


func _update_containing_rect_for_faction(i_faction : int) -> Rect2:
	# TODO in the future holding a handle to the goons could end up being faster - or not.
	var goons = UnitsRegister.get_goons(i_faction)
	if goons.is_empty():
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	var min_point = Vector2(1e308,1e308)
	var max_point = Vector2(-1e308,-1e308)
	for goon in goons:
		if not is_instance_valid(goon):
			continue
		var pos = goon.global_position
		min_point.x = min(pos.x, min_point.x)
		min_point.y = min(pos.y, min_point.y)
		max_point.x = max(pos.x, max_point.x)
		max_point.y = max(pos.y, max_point.y)
	latest_containing_rects[i_faction] = Rect2(min_point, max_point - min_point)
	elapsed_times[i_faction] = Time.get_ticks_msec()
	
	#if i_faction == 1:
		#print(latest_containing_rects[1])
		
	return latest_containing_rects[i_faction]
