class_name CardData
extends Node

var title = ""
var cost_1 = []
var text_1 = ""
var cost_2 = []
var text_2 = ""

static func new_card(i_title: String, i_cost_1: Array, i_text_1: String, i_cost_2: Array, i_text_2: String) -> CardData:
	var out_card = CardData.new()
	out_card.title = i_title
	out_card.cost_1 = i_cost_1
	out_card.text_1 = i_text_1
	out_card.cost_2 = i_cost_2
	out_card.text_2 = i_text_2
	return out_card
