extends Node2D

# A list of all the current units of the player.
var player_units = []
var level_cards = []
var dice_values = []

static var no_func = func(main): return

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
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
	units.append(PlayerUnit.new_unit(UnitParams.Types.SOLDIER))
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
	cards.append(generate_card_3())
	cards.append(generate_card_4())
	cards.append(generate_card_5())
	return cards

static func generate_card_1() -> CardData:
	
	return CardData.new_card(
		"The First Card", # Title
		[CardOption.new_option( # Option 1
			"An Easy Start",
			[[1, 1], [1, 1]],
			"a small horde approaches!",
			no_func,
			_create_list([[UnitParams.Types.SOLDIER,5],[UnitParams.Types.BUG,10]])
		),CardOption.new_option( # Option 2
			"Early Tanks",
			[[1,6], [6, 6]],
			"Harder enemies to begin",
			no_func,
			_create_list([[UnitParams.Types.TANK,3],[UnitParams.Types.BUG,5]])
		)])

static func generate_card_2() -> CardData:
	
	var func_2 = func(main):
		var goons = UnitsRegister.get_goons()

		for goon in goons:
			if not is_instance_valid(goon):
				continue
			if goon.FACTION != 1:
				main.get_node("UnitFactory").create_unit_by_type(UnitParams.Types.BUG, goon.global_position + Vector2(1,1), 0, 2)
		return
				
	return CardData.new_card(
		"The Second Card", # Title
		[CardOption.new_option( # Option 1
			"The horde continues ",
			[[1, 1]],
			"More stuff coming!",
			no_func,
			_create_list([[UnitParams.Types.BUG,15]])
		),CardOption.new_option( # Option 2
			"They can multiply?!",
			[[1, 6]],
			"All bugs multiply in number!",
			func_2,
			_create_list([[UnitParams.Types.TANK,1],[UnitParams.Types.BUG,4]])
		)])
	

static func generate_card_3() -> CardData:
	
	return CardData.new_card(
		"The Third Card", # Title
		[CardOption.new_option( # Option 1
			"A Lone Tank ",
			[[3, 3]],
			"You got lucky this time!",
			no_func,
			_create_list([[UnitParams.Types.TANK,1]])
		),CardOption.new_option( # Option 2
			"MORE BUGS!",
			[],
			"No more dice? bad luck!",
			no_func,
			_create_list([[UnitParams.Types.BUG,35]])
		)])
	

static func generate_card_4() -> CardData:
	
	var func_1 = func(main):
		var goons = UnitsRegister.get_goons()
		for goon in goons:
			if not is_instance_valid(goon):
				continue
			if goon.FACTION != 1:
				goon.health.receive_damage(100)
		return
	
	return CardData.new_card(
		"The Fourth Card", # Title
		[CardOption.new_option( # Option 1
			"Cleanup time! ",
			[[6, 6]],
			"let's kill it all!",
			func_1,
			[]
		),CardOption.new_option( # Option 2
			"MORE BUGS!",
			[],
			"No more dice? more bad luck!",
			no_func,
			_create_list([[UnitParams.Types.BUG,25]])
		)])

static func generate_card_5() -> CardData:
	return CardData.new_card(
		"The Final Card", # Title
		[CardOption.new_option( # Option 1
			"LAST PUSH!",
			[[1, 3],[1, 3]],
			"Juuuust a few more!",
			no_func,
			_create_list([[UnitParams.Types.BUG,25]])
		),CardOption.new_option( # Option 2
			"THE END",
			[[1,1]],
			"You might be dead.",
			no_func,
			_create_list([[UnitParams.Types.TANK,25]])
		)])
