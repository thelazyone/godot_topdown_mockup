class_name UnitParams
extends Node

# General Params
var name_id: String 		= "name"
var hp: float				= 100
var speed : float 			= 100	
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

static func get_soldier() -> UnitParams :
	var par = UnitParams.new()
	par.name_id = "Soldier"
	par.hp = 100
	par.speed = 100
	par.spotting_range = 500
	par.attack_speed = 500
	par.attack_damage = 2
	par.attack_range = 500
	par.threats_weight = 5
	par.threats_range = 100
	par.targets_weight = 5
	par.targets_range = 500
	par.targets_min_range = 100
	par.orders_weight = 5
	return par

static func get_bug() -> UnitParams :
	var par = UnitParams.new()
	par.name_id = "Bug"
	par.hp = 60
	par.speed = 150
	par.spotting_range = 500
	par.attack_speed = 200
	par.attack_damage = 2
	par.attack_range = 50
	par.threats_weight = 0
	par.threats_range = 100
	par.targets_weight =10
	par.targets_range = 1500
	par.targets_min_range = 0
	par.orders_weight = 1
	return par
