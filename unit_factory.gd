extends Node2D
const goon_scene = preload("res://scenes/actors/goon.tscn")

# Public Method
func create_unit(i_params: UnitParams, i_position: Vector2, i_faction: int) -> Node:
	var goon = goon_scene.instantiate()
	goon.position = i_position
	goon.FACTION = i_faction
	goon.add_to_group("goons")
	
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
