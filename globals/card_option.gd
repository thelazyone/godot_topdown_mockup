class_name CardOption
extends Node

var title : String = ""
var cost : Array = []
var text : String = ""
var effect : Callable = func(): return
var spawn : Array = []

static func new_option(\
	i_title: String, \
	i_cost: Array, \
	i_text: String, \
	i_effect: Callable, \
	i_spawn: Array) -> CardOption:
		
	var out_option = CardOption.new()
	out_option.title = i_title
	out_option.cost = i_cost
	out_option.text = i_text
	out_option.effect = i_effect
	out_option.spawn = i_spawn
	return out_option
