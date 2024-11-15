class_name PlayerUnit
extends Node

var id : int = 0 # Unique ID, tracked throughout the game. # TODO could be a dict?
var type : UnitParams.Types = UnitParams.Types.SOLDIER
var xp : float = 0 # For levelling up; each 100 is a level (TODO)
var formation_position : Vector2 = Vector2.ZERO # For formations (TODO)
var wounds : float = 0 # 0 to 1, level of wound (TODO)
var out_of_combat : bool = false # If true, the unit is healing (TODO)

# Get Type

# Constructor
static func new_unit(type : UnitParams.Types):
	var out_unit = PlayerUnit.new()
	out_unit.type = type
	out_unit.id = randi() 	# TODO risk of collision! how to get a truly unique ID?
	return out_unit
