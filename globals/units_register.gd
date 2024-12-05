extends Node

var current_goons = []
var current_goons_per_faction = {}

func update_goons():
	current_goons = get_tree().get_nodes_in_group("goons")
	for goon in current_goons:
		if not goon.FACTION in current_goons_per_faction:
			current_goons_per_faction[goon.FACTION] = []
		current_goons_per_faction[goon.FACTION].append(goon)
	
func add_goon(goon):
	current_goons.append(goon)
	if not goon.FACTION in current_goons_per_faction:
		current_goons_per_faction[goon.FACTION] = []
	current_goons_per_faction[goon.FACTION].append(goon)

func get_goons(faction : int = -1):
	if faction < 0: 
		return current_goons
	else:
		if not faction in current_goons_per_faction:
			return current_goons
		return current_goons_per_faction[faction]
