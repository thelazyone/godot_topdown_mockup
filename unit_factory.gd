extends Node2D
const goon_scene = preload("res://scenes/actors/goon.tscn")

# Public Method
func create_unit(i_params: UnitParams, i_position: Vector2, i_faction: int, i_parent) -> Node:
	
	var goon = goon_scene.instantiate()
	goon.position = i_position
	goon.FACTION = i_faction
	goon.add_to_group("goons")
	
	i_parent.add_child(goon)
	
	# Setting the MELEE params
	if i_params.melee == true: 
		goon.field.threats_weight = 0
		goon.field.targets_weight = 30
		goon.field.orders_weight = 0.1
		goon.WEAPON_RANGE = 15
	else:
		goon.field.threats_weight = 200
		goon.field.targets_weight = 20
		goon.WEAPON_RANGE = 500
		goon.SPOTTING_RANGE = 500
		
	goon.SPEED = i_params.speed
	goon.shoot.COOLDOWN_TIME_MS = i_params.shoot_speed
	
	
	# Custom color code, very TODO / TBR:
	if (goon.FACTION > 1):
		goon.get_node("Image").self_modulate = Color(1,.6,.6,1)
	else:
		goon.get_node("Image").self_modulate = Color(.6,.6,1,1)

	# Skip most of the params for now (TODO)
	
	return goon
	
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
