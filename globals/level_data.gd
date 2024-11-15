extends Node2D

# A list of all the current units of the player.
var player_units = []
var level_cards = []
var car

func _init() -> void:
	player_units = get_starting_units()
	level_cards = get_starting_cards()
	
# Public Methods
func update_unit(id: int, xp: int, formation: Vector2, wounds: float, out_of_combat: bool):
	var unit_found : bool = false
	for unit in player_units:
		if unit.id == id:
			unit.xp = xp
			unit.formation = formation
			unit.wounds = wounds
			unit.out_of_combat = out_of_combat
			unit_found = true
	return unit_found
		
static func get_starting_units() -> Array :
	var units = []
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.TANK))
	units.append(PlayerUnit.new_unit(UnitParams.Types.TANK))
	units.append(PlayerUnit.new_unit(UnitParams.Types.TANK))
	units.append(PlayerUnit.new_unit(UnitParams.Types.TANK))
	return units

static func get_starting_cards() -> Array :
	var cards = []
	cards.append(CardData.new_card(\
		"Card 1",
		[[1,4],2],
		"Option 1",
		[[5,6],[5,6]],
		"Option 2"))
	cards.append(CardData.new_card(\
		"Card 2",
		[2],
		"Option 1",
		[1],
		"Option 2"))
	cards.append(CardData.new_card(\
		"Card 3",
		[],
		"Option 1",
		[[1,6]],
		"Option 2"))
	return cards
