class_name UnitParams
extends Node

var name_id: String 
var hp: float
var speed : float
var melee: bool

# Custom constructor
func _init():
	name_id = "name"
	hp = 100
	speed = 100
	melee = false


func new() -> UnitParams:
	var params = UnitParams.new()
	params._init()
	return params
