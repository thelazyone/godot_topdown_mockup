extends Node2D
const goon_scene = preload("res://scenes/actors/goon.tscn")

# Public Method
func create_unit(i_params: UnitParams, i_position: Vector2, i_id: int, i_faction: int, i_parent) -> Node:
	
	var goon = goon_scene.instantiate()
	goon.position = i_position
	goon.FACTION = i_faction
	goon.ID = i_id
	goon.add_to_group("goons")
	i_parent.add_child(goon)
	
	# General Params
	goon.NAME = i_params.name_id
	goon.health.health = i_params.hp
	goon.get_node("Image").texture = load(i_params.icon)
	goon.SPEED = i_params.speed
	goon.SPOTTING_RANGE = i_params.spotting_range

	# Attack Params
	goon.shoot.COOLDOWN_TIME_MS = i_params.attack_speed
	goon.shoot.PROJECTILE.DAMAGE = i_params.attack_damage
	goon.shoot.PROJECTILE.DURATION_MS = i_params.attack_range * 2
	goon.shoot.PROJECTILE.UNIT_ID = goon.ID
	goon.WEAPON_RANGE = i_params.attack_range

	# Behaviour Fields Params
	# Threats Field
	goon.field.threats_weight = i_params.threats_weight
	goon.field.threats_range = i_params.threats_range

	# Targets Field
	goon.field.targets_weight = i_params.targets_weight
	goon.field.targets_range = i_params.targets_range
	goon.field.targets_min_range = i_params.targets_min_range

	# Orders Field
	if goon.FACTION != 1:
		goon.field.orders_weight = 0
	else:
		goon.field.orders_weight = i_params.orders_weight

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
	pass
