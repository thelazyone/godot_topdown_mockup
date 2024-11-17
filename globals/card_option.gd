class_name CardOption
extends Node

var title = ""
var cost = []
var text = ""
var effect : Callable

static func new_option(\
	i_title: String, \
	i_cost: Array, \
	i_text: String, \
	i_effect: Callable) -> CardOption:
		
	var out_option = CardOption.new()
	out_option.title = i_title
	out_option.cost = i_cost
	out_option.text = i_text
	out_option.effect = i_effect
	return out_option
