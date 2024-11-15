extends Node2D

# A list of all the current units of the player.
var player_units = []

func _init() -> void:
	player_units = get_starting_units()

# Public Methods
func get_starting_units() -> Array :
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
