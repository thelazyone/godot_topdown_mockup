class_name UnitParams
extends Node

enum Types{SOLDIER, TANK, BUG, TOTEM}

# General Params
var name_id: String 		= "name"
var hp: float				= 100
var speed : float 			= 100	
var icon : String			= ""
var spotting_range : float  = 500

# Attack Params
var attack_speed : float	= 500
var attack_damage : float	= 2
var attack_range : float 	= 200

# Behaviour Fields Params
# Threats Field
var threats_weight : float	= 5
var threats_range : float	= 150

# Targets Field
var targets_weight : float	= 5
var targets_range : float	= 200
var targets_min_range : float	= 50

# Orders Field
var orders_weight : float	= 5

static func get_unit_params(unit_type : Types) -> UnitParams :
	
	var par = UnitParams.new()
	match unit_type:
		Types.SOLDIER:
			par.name_id = "Soldier"
			par.icon = "res://scenes/actors/enlisted_troop_gun.png"
			par.hp = 10
			par.speed = 100
			par.spotting_range = 500
			par.attack_speed = 250
			par.attack_damage = 1
			par.attack_range = 200
			par.threats_weight = 5
			par.threats_range = 100
			par.targets_weight = 6
			par.targets_range = 500
			par.targets_min_range = 200
			par.orders_weight = 10
		Types.TANK:
			par.name_id = "Tank"
			par.icon = "res://scenes/actors/enlisted_tank.png"
			par.hp = 40
			par.speed = 200 #was 60
			par.spotting_range = 800
			par.attack_speed = 200 # Was 2000
			par.attack_damage = 20
			par.attack_range = 800
			par.threats_weight = 5
			par.threats_range = 100
			par.targets_weight = 10
			par.targets_range = 500
			par.targets_min_range = 300
			par.orders_weight = 10
		Types.BUG:
			par.name_id = "Bug"
			par.icon = "res://scenes/actors/bug.png"
			par.hp = 6
			par.speed = 150
			par.spotting_range = 500
			par.attack_speed = 200
			par.attack_damage = 2
			par.attack_range = 50
			par.threats_weight = 0
			par.threats_range = 100
			par.targets_weight = 3
			par.targets_range = 1500
			par.targets_min_range = 0
			par.orders_weight = 1
		Types.TOTEM:
			par.name_id = "Totem"
			par.icon = "res://scenes/actors/enlisted_troop_gun.png"
			par.hp = 200
			par.speed = 0
			par.spotting_range = 500
			par.attack_speed = 50
			par.attack_damage = 2
			par.attack_range = 100
			par.threats_weight = 5
			par.threats_range = 100
			par.targets_weight = 5
			par.targets_range = 500
			par.targets_min_range = 100
			par.orders_weight = 10
	
	return par
