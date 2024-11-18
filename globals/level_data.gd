extends Node2D

# A list of all the current units of the player.
var player_units = []
var level_cards = []
var dice_values = []

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
	units.append(PlayerUnit.new_unit(UnitParams.Types.TANK))
	units.append(PlayerUnit.new_unit(UnitParams.Types.TANK))
	return units
	
static func _create_list(list : Array) -> Array:
	# Expecting inputs in the form [UnitParams.Type, int]
	var out_list = []
	for block in list:
		for i in range (block[1]):
			out_list.append(block[0])
	return out_list
	

static func get_starting_cards() -> Array :
	var cards = []
	
	cards.append(generate_card_1())
	cards.append(generate_card_2())
	cards.append(generate_card_2())
	cards.append(generate_card_2())
	cards.append(generate_card_2())
	return cards

static func generate_card_1() -> CardData:
	
	var func_1 = func():
		return _create_list([[UnitParams.Types.BUG,10]])
	
	var func_2 = func():
		return _create_list([[UnitParams.Types.TANK,1],[UnitParams.Types.BUG,2]])

	return CardData.new_card(
		"The First Card", # Title
		[CardOption.new_option( # Option 1
			"CARD OPTION 1",
			[[1, 1], [1, 1]],
			"Does something",
			func_1
		),CardOption.new_option( # Option 2
			"CARD OPTION 2",
			[[1,6], [6, 6]],
			"Does something else",
			func_2
		)])

static func generate_card_2() -> CardData:
	
	var func_1 = func():
		return _create_list([[UnitParams.Types.BUG,5]])
	
	var func_2 = func():
		return _create_list([[UnitParams.Types.TANK,1],[UnitParams.Types.BUG,2]])

	return CardData.new_card(
		"The First Card", # Title
		[CardOption.new_option( # Option 1
			"CARD OPTION 1",
			[[1, 6]],
			"Does something",
			func_1
		),CardOption.new_option( # Option 2
			"CARD OPTION 2",
			[[1, 6]],
			"Does something else",
			func_2
		)])
