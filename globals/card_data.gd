class_name CardData
extends Node

var options = [] # Array of card_option
var title = ""

static func new_card(\
	i_title: String, \
	i_options : Array) -> CardData:
		
	var out_card = CardData.new()
	out_card.title = i_title
	out_card.options = i_options
	return out_card
